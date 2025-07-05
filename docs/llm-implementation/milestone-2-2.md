# Milestone 2.2: CSV Upload Implementation Summary

This document summarizes the steps taken to implement the CSV upload feature.

## Terminal Commands

The following terminal commands were used during development:

1.  **Generate `UploadsController`**:
    ```bash
    docker-compose run --rm web rails g controller Uploads --skip-routes
    ```

2.  **Run RSpec tests for `UploadsController`**:
    ```bash
    docker-compose run --rm test bundle exec rspec spec/requests/uploads_spec.rb
    ```

## Code Changes

### 1. Routes

In `config/routes.rb`, routes were added for the `uploads` resource:

```ruby
resources :uploads, only: [:index, :new, :create, :show]
```

### 2. Controller

The `app/controllers/uploads_controller.rb` was created and implemented with the following logic:
- A `before_action` to ensure user authentication.
- `index`, `show`, and `new` actions for basic CRUD operations.
- A `create` action that handles the file upload. This action delegates the core logic to a private `process_csv_upload` method.
- The `process_csv_upload` method performs the following validations:
    - Checks for file presence.
    - Validates the file is a `.csv` with the correct MIME type.
    - Ensures the file is not empty.
    - Calculates a SHA256 hash of the file content to prevent duplicate uploads.
    - Parses the CSV and verifies that all rows have a consistent number of columns.
- On successful validation, it creates an `Upload` record and an `UploadRow` for each row in the CSV.
- It provides clear error messages on failure.

### 3. Views

- **`app/views/uploads/new.html.erb`**: A form for uploading a new CSV file.
- **`app/views/uploads/index.html.erb`**: A page that lists all of the current user's uploads.
- **`app/views/uploads/show.html.erb`**: A page that displays the details of a single upload, including its metadata and a table of its row data.
- **`app/views/layouts/application.html.erb`**: Added flash message rendering to display success and error messages.

### 4. Testing

- **Fixture Files**: To facilitate testing, the following fixture files were created in `spec/fixtures/files/`:
    - `valid.csv`: A well-formed CSV file.
    - `empty.csv`: An empty file.
    - `malformed.csv`: A CSV with inconsistent column counts.
    - `wrong_type.txt`: A non-CSV file.

- **Request Specs**: In `spec/requests/uploads_spec.rb`, a comprehensive test suite was written to cover:
    - Authentication requirements.
    - The "happy path" of a valid file upload.
    - Failure cases for all validations: incorrect file type, empty file, inconsistent columns, duplicate files, and no file selected.

### 5. Bug Fixes

During testing, two main issues were identified and resolved:
1.  An `ActiveModel::UnknownAttributeError` occurred because the controller was using `row_number` and `data` while the `UploadRow` model and migration used `row_index` and `values`. The controller and views were updated to align with the database schema.
2.  Flash messages for error conditions were not appearing. This was fixed by adding the necessary ERB tags to `app/views/layouts/application.html.erb` to render the `notice` and `alert` flash messages.

After these fixes, all tests passed successfully.
