# Milestone: Admin Uploads View

This document summarizes the steps taken to implement an admin-only section for viewing all user uploads.

## 1. Add Pagination Gem

The `pagy` gem was added for pagination.

**File:** `Gemfile`

```ruby
# ... existing code ...
gem "googleauth"
gem "pagy"

group :development, :test do
# ... existing code ...
```

The duplicate `faker` gem was also removed.

```ruby
# ... existing code ...
gem "dotenv-rails", groups: [:development, :test]

gem "googleauth"
gem "pagy"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
# ... existing code ...
  gem "rspec-rails", "~> 6.0"
  gem "factory_bot_rails"
  gem "faker"
  gem "pry-rails"
end
# ... existing code ...
```

Then gems were installed using `bundle install` within the Docker containers.

```bash
docker-compose run --rm web bundle install
docker-compose run --rm test bundle install
```

## 2. Configure Pagy

Pagy was configured in the application controllers and helpers.

**File:** `app/controllers/application_controller.rb`

```ruby
class ApplicationController < ActionController::Base
  include Pagy::Backend
  # ... existing code ...
end
```

**File:** `app/helpers/application_helper.rb`

```ruby
module ApplicationHelper
  include Pagy::Frontend
end
```

An initializer was added to load the Bootstrap extras for styling.

**File:** `config/initializers/pagy.rb`

```ruby
# frozen_string_literal: true

# Pagy initializer file
# See https://ddnexus.github.io/pagy/docs/extras/bootstrap

# Load the bootstrap extra
require "pagy/extras/bootstrap"

# Set the default number of items per page
Pagy::DEFAULT[:items] = 10
```

## 3. Create Admin Routes

Namespaced routes were added for the admin section.

**File:** `config/routes.rb`
```ruby
# ... existing code ...
  resources :uploads, only: [:new, :create, :show] do
    get :download, on: :member
  end

  namespace :admin do
    resources :uploads, only: [:index, :show]
  end
# ... existing code ...
```

## 4. Implement Admin Controller

The `Admin::UploadsController` was created to handle the logic.

**File:** `app/controllers/admin/uploads_controller.rb`

```ruby
class Admin::UploadsController < ApplicationController
  before_action :authorize_admin

  def index
    @pagy, @uploads = pagy(Upload.all.order(created_at: :desc))
  end

  def show
    @upload = Upload.find(params[:id])
  end

  private

  def authorize_admin
    redirect_to root_path, alert: "You are not authorized to perform this action." unless current_user.admin?
  end
end
```

This required adding an `admin?` method to the `User` model.

**File:** `app/models/user.rb`
```ruby
# ... existing code ...
      user.name = auth.info.name
      user.uid = auth.uid
    end
  end

  def admin?
    email == "klenwell@gmail.com"
  end
end
```

## 5. Create Admin Views

Views were created for the `index` and `show` actions.

**File:** `app/views/admin/uploads/index.html.erb`

```html
<div class="container">
  <h1>Admin - All Uploads</h1>

  <table class="table">
    <thead>
      <tr>
        <th>User</th>
        <th>Filename</th>
        <th>Created At</th>
        <th>Actions</th>
      </tr>
    </thead>
    <tbody>
      <% @uploads.each do |upload| %>
        <tr>
          <td><%= upload.user.email %></td>
          <td><%= upload.filename %></td>
          <td><%= time_ago_in_words(upload.created_at) %> ago</td>
          <td><%= link_to 'Show', admin_upload_path(upload), class: 'btn btn-primary' %></td>
        </tr>
      <% end %>
    </tbody>
  </table>

  <%== pagy_bootstrap_nav(@pagy) %>
</div>
```

**File:** `app/views/admin/uploads/show.html.erb`
```html
<div class="container">
  <h1>Upload Details</h1>

  <p><strong>User:</strong> <%= @upload.user.email %></p>
  <p><strong>Filename:</strong> <%= @upload.filename %></p>
  <p><strong>Created At:</strong> <%= @upload.created_at %></p>

  <h2>Upload Rows</h2>
  <table class="table">
    <thead>
      <tr>
        <th>Data</th>
        <th>Status</th>
      </tr>
    </thead>
    <tbody>
      <% @upload.upload_rows.each do |row| %>
        <tr>
          <td><%= row.data %></td>
          <td><%= row.status %></td>
        </tr>
      <% end %>
    </tbody>
  </table>

  <%= link_to 'Back to Admin Uploads', admin_uploads_path, class: 'btn btn-secondary' %>
</div>
```

## 6. Add Feature Specs

Feature specs were added to test the new functionality.

**File:** `spec/requests/admin/uploads_spec.rb`

```ruby
require 'rails_helper'

RSpec.describe "Admin::Uploads", type: :request do
  let(:admin_user) { create(:user, email: 'klenwell@gmail.com', uid: '123456') }
  let(:regular_user) { create(:user, uid: '654321') }
  let!(:upload) { create(:upload, user: regular_user) }

  describe "GET /admin/uploads" do
    context "when logged in as admin" do
      before do
        sign_in(admin_user)
        get admin_uploads_path
      end

      it "returns a successful response" do
        expect(response).to be_successful
      end

      it "displays the upload" do
        expect(response.body).to include(upload.filename)
      end
    end

    context "when logged in as a regular user" do
      before do
        sign_in(regular_user)
        get admin_uploads_path
      end

      it "redirects to the root path" do
        expect(response).to redirect_to(root_path)
      end
    end

    context "when not logged in" do
      it "redirects to the login page" do
        get admin_uploads_path
        expect(response).to redirect_to("/auth/google_oauth2")
      end
    end
  end

  describe "GET /admin/uploads/:id" do
    context "when logged in as admin" do
      before do
        sign_in(admin_user)
        get admin_upload_path(upload)
      end

      it "returns a successful response" do
        expect(response).to be_successful
      end

      it "displays the upload details" do
        expect(response.body).to include(upload.filename)
      end
    end

    context "when logged in as a regular user" do
      before do
        sign_in(regular_user)
        get admin_upload_path(upload)
      end

      it "redirects to the root path" do
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
```

Test helpers for OmniAuth were also configured.

**File:** `spec/rails_helper.rb` (additions)
```ruby
# ...
OmniAuth.config.test_mode = true
require_relative 'support/omniauth_macros'

RSpec.configure do |config|
  # ...
  config.include OmniauthMacros, type: :request

  def sign_in(user)
    mock_auth_hash(user)
    get '/auth/google_oauth2/callback'
  end
end
```

**File:** `spec/support/omniauth_macros.rb` (new file)
```ruby
module OmniauthMacros
  def mock_auth_hash(user)
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      'provider' => 'google_oauth2',
      'uid' => user.uid,
      'info' => {
        'name' => user.name,
        'email' => user.email
      }
    })
  end
end
```

## 7. Docker Environment Fixes

Several changes were made to the Docker configuration to ensure the test environment runs correctly.

Added `/vendor/bundle` to `.gitignore`.

**File:** `.gitignore`
```
# ...
/vendor/bundle
# ...
```

**File:** `Dockerfile`
```dockerfile
# ...
# Create a non-root user
RUN useradd -u 1000 -m app && \
    chown -R app:app /home/app

# Create and set ownership for the app directory
RUN mkdir /app && chown -R app:app /app

WORKDIR /app

# Add the gem bin path to the PATH
ENV PATH="/app/vendor/bundle/bin:/app/vendor/bundle/ruby/3.2.0/bin:${PATH}"

# Switch to non-root user
USER app

# Configure bundler to install gems to vendor/bundle
RUN bundle config set --local path 'vendor/bundle'

# Install all gems
COPY --chown=app:app Gemfile Gemfile.lock ./
RUN bundle install -j 4
# ...
```

**File:** `docker-compose.yml`
```yaml
# ...
  web:
    build:
      context: .
      target: base
    command: bash -c "rm -f tmp/pids/server.pid && bundle exec rails s -p 3000 -b '0.0.0.0'"
    volumes:
      - .:/app
      - gems:/app/vendor/bundle
# ...
  test:
    build:
      context: .
      target: base
    command: bundle exec rspec
    volumes:
      - .:/app
      - gems:/app/vendor/bundle
# ...
volumes:
  postgres_data:
  gems: {}
```

The Docker image was rebuilt after these changes.
```bash
docker-compose build --no-cache
```
