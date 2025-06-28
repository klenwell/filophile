# Milestone 3.1: Basic Bootstrap UI for Uploads

This document outlines the steps taken to implement a basic Bootstrap-styled UI for users to manage their file uploads.

### 1. Dependency and Asset Pipeline Setup

The first step was to integrate Bootstrap into the application. The initial approach using `importmap` for CSS assets proved problematic in the test environment. The strategy was pivoted to use the traditional Sprockets pipeline with gems, which is more robust for this setup.

**Commands:**

- Pin initial JS dependencies (later reverted):
  ```bash
  docker-compose run --rm web ./bin/importmap pin bootstrap popper.js
  ```
- Rename CSS to SCSS to allow for `@import`:
  ```bash
  mv app/assets/stylesheets/application.css app/assets/stylesheets/application.scss
  ```
- Add gems for SCSS compilation and Bootstrap assets:
  ```diff
  --- a/Gemfile
  +++ b/Gemfile
  @@ -20,6 +20,9 @@
   # Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
   gem "importmap-rails"

  +gem "jquery-rails"
  +gem "bootstrap", "~> 5.3.3"
  +gem "sassc-rails"
  +
   # Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
   gem "turbo-rails"

  ```
- Install the new gems:
  ```bash
  docker-compose run --rm web bundle install
  ```
- Rebuild the test container to include the new gems:
  ```bash
  docker-compose build test
  ```

**Asset Configuration:**

- The importmap was cleaned of the Bootstrap-related pins since the `bootstrap` gem would now handle them.
  ```diff
  --- a/config/importmap.rb
  +++ b/config/importmap.rb
  @@ -6,6 +6,3 @@
   pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
   pin_all_from "app/javascript/controllers", under: "controllers"

  -pin "bootstrap" # @5.3.7
  -pin "popper.js" # @1.16.1
  -pin "@popperjs/core", to: "@popperjs--core.js" # @2.11.8
  ```
- `application.js` was updated to use Sprockets `require` directives instead of ES6 `import`.
  ```diff
  --- a/app/javascript/application.js
  +++ b/app/javascript/application.js
  @@ -1,5 +1,7 @@
   // Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
   import "@hotwired/turbo-rails"
   import "controllers"
  -import "bootstrap"
  -import "@popperjs/core"
  +
  +//= require jquery3
  +//= require popper
  +//= require bootstrap
  ```
- `application.scss` was updated to import Bootstrap from the gem.
  ```diff
  --- a/app/assets/stylesheets/application.scss
  +++ b/app/assets/stylesheets/application.scss
  @@ -11,5 +11,3 @@
    * It is generally better to create a new file per style scope.
    */

  -@import "bootstrap/scss/bootstrap";
  +@import "bootstrap";
  ```
- The asset manifest was updated to link both `.scss` and the compiled `application.css` to fix precompilation errors in the test environment.
  ```diff
  --- a/app/assets/config/manifest.js
  +++ b/app/assets/config/manifest.js
  @@ -1,4 +1,5 @@
   //= link_tree ../images
  -//= link_directory ../stylesheets .css
  +//= link_directory ../stylesheets .scss
  +//= link application.css
   //= link_tree ../../javascript .js
   //= link_tree ../../../vendor/javascript .js
  ```

### 2. Routes and Controller Actions

Routes were added for the new dashboard and download functionality. The `UploadsController` was updated to handle these new actions and to ensure data was properly scoped and paginated for views.

**Routes (`config/routes.rb`):**

```diff
--- a/config/routes.rb
+++ b/config/routes.rb
@@ -7,9 +7,11 @@
   get "/auth/google_oauth2/callback", to: "sessions#create"
   delete "/logout", to: "sessions#destroy"

-  resources :uploads, only: [:index, :new, :create, :show]
+  get "/dashboard", to: "uploads#index"

-  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
+  resources :uploads, only: [:new, :create, :show] do
+    get :download, on: :member
+  end

   # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
   # Can be used by load balancers and uptime monitors to verify that the app is live.

```

**Controller (`app/controllers/uploads_controller.rb`):**

- The `show` action was updated to limit the preview data to the first 10 rows.
- The `download` action was added to serve the original file.
```diff
--- a/app/controllers/uploads_controller.rb
+++ b/app/controllers/uploads_controller.rb
@@ -5,15 +5,21 @@
   end

   def show
-    @upload = find_upload
+    @upload = find_upload_
+    @upload_rows = @upload.upload_rows.order(:row_index).limit(10)
   end

   def new
     @upload = Upload.new
   end

   def create
     uploaded_io = params[:upload][:original_file]
     unless uploaded_io
       redirect_to new_upload_path, alert: 'Please select a file to upload.'
       return
     end

     process_csv_upload(uploaded_io)
   end

+  def download
+    @upload = find_upload
+    send_data @upload.original_file.download, filename: @upload.filename, content_type: 'text/csv'
+  end
+
   private

   def find_upload
```

- A global `rescue_from` was added to `ApplicationController` to gracefully handle `RecordNotFound` errors with a 404 response.
```diff
--- a/app/controllers/application_controller.rb
+++ b/app/controllers/application_controller.rb
@@ -2,6 +2,8 @@
   before_action :authenticate_user!

   helper_method :current_user
+
+  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

   private

@@ -12,4 +14,8 @@
   def authenticate_user!
     redirect_to "/auth/google_oauth2" unless current_user
   end
+
+  def record_not_found
+    render plain: "404 Not Found", status: :not_found
+  end
 end
```

### 3. Views

The views were created and updated to use Bootstrap for styling, providing a clean and responsive user interface.

- **`application.html.erb`**: A full layout overhaul with a navbar and styled flash messages.
- **`uploads/index.html.erb`**: Transformed into a "Dashboard" listing the user's uploads with action buttons.
- **`uploads/new.html.erb`**: A styled file upload form.
- **`uploads/show.html.erb`**: A detailed view with upload metadata and a preview table of the first 10 rows.

### 4. Feature Specs and Debugging

Feature specs were written to ensure all new functionality worked as expected and was secure. The process involved significant debugging.

**Spec File (`spec/requests/uploads_spec.rb`):**
- Added tests for the dashboard, show, and download actions.
- Ensured that users could only see and interact with their own uploads.

**Debugging Steps:**
1.  **Factory Error**: The initial tests failed due to a `RecordNotUnique` error. The `user` factory was updated to generate unique emails using a sequence.
    ```diff
    --- a/spec/factories/users.rb
    +++ b/spec/factories/users.rb
    @@ -1,9 +1,9 @@
     FactoryBot.define do
       factory :user do
    -    email { "MyString" }
    -    name { "MyString" }
    -    uid { "MyString" }
    -    provider { "MyString" }
    +    sequence(:email) { |n| "user#{n}@example.com" }
    +    sequence(:name) { |n| "User Name #{n}" }
    +    sequence(:uid) { |n| "uid#{n}" }
    +    provider { "google_oauth2" }
         admin { false }
       end
     end
    ```
2.  **Asset Pipeline Errors**: A series of asset-related errors were fixed by switching from `importmap` for CSS to the `bootstrap` gem and correctly configuring Sprockets.
3.  **Authorization Test Fix**: After adding the `rescue_from` in the `ApplicationController`, the authorization tests were updated to check for a `404 Not Found` status instead of a raised `ActiveRecord::RecordNotFound` error.
    ```diff
    --- a/spec/requests/uploads_spec.rb
    +++ b/spec/requests/uploads_spec.rb
    @@ -40,10 +40,8 @@
     end

     context "when viewing other user's upload" do
    -  it "raises a RecordNotFound error" do
    -    expect {
    -      get upload_path(other_user_upload)
    -    }.to raise_error(ActiveRecord::RecordNotFound)
    +  it "returns a 404 not found response" do
    +    get upload_path(other_user_upload)
    +    expect(response).to have_http_status(:not_found)
       end
     end
    ...
    @@ -67,10 +65,8 @@
     end

     context "when downloading other user's upload" do
    -  it "raises a RecordNotFound error" do
    -    expect {
    -      get download_upload_path(other_user_upload)
    -    }.to raise_error(ActiveRecord::RecordNotFound)
    +  it "returns a 404 not found response" do
    +    get download_upload_path(other_user_upload)
    +    expect(response).to have_http_status(:not_found)
       end
     end
    ```

After these changes, all tests passed, confirming the successful implementation of the new UI and features.
