# implementation.md

## 🔧 Phase 1: Project Setup

### ✅ Milestone 1.1: Initialize Rails App with Docker and PostgreSQL

**Objective**: Establish a Rails development environment with Docker and PostgreSQL.

#### Steps:
- Scaffold Rails app (latest stable version)
- Set up Docker and Docker Compose
- Connect to PostgreSQL
- Add RSpec and supporting tools

#### Prompt:
```text
Create a new Rails app called `file_uploader` using the latest stable Rails version, with PostgreSQL as the default database.

Add Docker and Docker Compose configuration for local development. Include services for:
- `web` (Rails app)
- `db` (PostgreSQL 14)

Ensure `web` connects to `db` with proper environment variables. Mount the local app into the container.

Install and configure RSpec, FactoryBot, and other basic dev tools (e.g., RuboCop, Guard). Add a basic `health_check_spec` that passes.
```

---

### ✅ Milestone 1.2: User Authentication with Google OAuth

**Objective**: Implement secure login via Google OAuth and persist sessions.

#### Steps:
- Add `omniauth-google-oauth2` gem
- Add `User` model and session logic
- Support login/logout
- Add authentication before action
- Protect all routes

#### Prompt:
```text
Add user authentication using `omniauth-google-oauth2`.

Generate a `User` model with the following fields:
- `email` (string, unique, required)
- `name` (string)
- `uid` (string)
- `provider` (string, default: "google_oauth2")
- `admin` (boolean, default: false)

Set up OmniAuth middleware and routes for login (`/auth/google_oauth2/callback`) and logout.

Create `SessionsController` with `create` and `destroy` actions.

Add a before_action that requires authentication for all controllers.

Write request specs for session logic and test login flow with mocked OmniAuth response.
```

---

## 📦 Phase 2: Upload Management Backend

### ✅ Milestone 2.1: Create Upload Models and Associations

**Objective**: Set up core data models for file storage.

#### Steps:
- Create `Upload` and `UploadRow` models
- Define associations
- Write specs

#### Prompt:
```text
Generate the following models:

**Upload**
- `user_id`: integer (FK)
- `filename`: string
- `content_hash`: string (unique)
- `row_count`: integer
- `column_count`: integer
- `uploaded_at`: datetime
- `original_file`: binary or text (for storing file blob or path)

**UploadRow**
- `upload_id`: integer (FK)
- `row_index`: integer
- `values`: JSON (array of strings)

Add associations:
- `User has_many :uploads`
- `Upload belongs_to :user` and `has_many :upload_rows`
- `UploadRow belongs_to :upload`

Add model validations and database constraints. Write full model specs.
```

---

### ✅ Milestone 2.2: File Upload API with Validation

**Objective**: Accept CSV files, validate contents, and persist to DB.

#### Steps:
- Create `UploadsController`
- Add file upload endpoint
- Validate MIME type, columns, and duplicates
- Parse and store rows

#### Prompt:
```text
Create `UploadsController` with a `create` action that allows authenticated users to upload CSV files.

Perform the following validations:
- File must be `.csv` and have proper MIME type
- All rows must have same number of columns
- File must not be empty
- Reject duplicate uploads based on SHA256 hash of normalized contents

On success:
- Save `Upload` record and metadata
- Save full contents of file (binary or string)
- Parse and store each row as an `UploadRow`

On failure:
- Show clear error messages

Write request specs for happy and failure paths.
```

---

## 🔍 Phase 3: Views and Permissions

### ✅ Milestone 3.1: User-Facing Upload Views

**Objective**: Build a UI for regular users to manage their uploads.

#### Steps:
- Add file upload form
- Add uploads index and show views
- Add download action

#### Prompt:
```text
Implement a basic Bootstrap-styled UI for users to manage their uploads.

Add these views:
- `/dashboard`: lists the current user's uploads
- `/uploads/:id`: shows upload metadata and preview table (first 10 rows)
- `/uploads/:id/download`: downloads the original uploaded file

Include a file upload form that POSTs to `/uploads`.

Restrict visibility to the logged-in user's uploads. Write feature specs.
```

---

### ✅ Milestone 3.2: Admin Upload Views

**Objective**: Create a view for admin users to inspect all uploads.

#### Steps:
- Add `/admin/uploads` index
- Add `/admin/uploads/:id` show
- Enforce admin check
- Paginate uploads

#### Prompt:
```text
Add admin-only views to list and inspect all uploads.

Create a namespace `Admin::UploadsController`.

Routes:
- `/admin/uploads` (index)
- `/admin/uploads/:id` (show)

Add pagination (e.g., with Kaminari or Pagy).

Restrict controller access to `current_user.admin? == true`.

Add feature specs for admin views and authorization.
```

---

## ✅ Phase 4: Finishing Touches

### ✅ Milestone 4.1: Role-Based Access + Error Handling

**Objective**: Ensure users can't access unauthorized resources.

#### Steps:
- Add `before_action` guards to all controllers
- Raise or redirect on forbidden access
- Add 404s for bad IDs
- Add test coverage

#### Prompt:
```text
Ensure all actions are protected:

- Users cannot view uploads they don’t own
- Admins can view all uploads
- Unauthorized users are redirected or receive 403
- Invalid IDs raise 404

Write request specs for these cases.
```

---

### ✅ Milestone 4.2: UI Polish + CI Integration

**Objective**: Finalize UI, add CI, and validate test coverage.

#### Steps:
- Add Bootstrap styling
- Integrate CI (e.g., GitHub Actions)
- Add linting, RuboCop config
- Ensure 100% test pass

#### Prompt:
```text
Style all views with Bootstrap (layout, buttons, tables, alerts).

Set up GitHub Actions to run RSpec and RuboCop on each push.

Add final spec coverage for any missing cases:
- Invalid file formats
- Empty CSV
- Upload deletion (optional)

Ensure that `bundle exec rspec` passes all specs.
```

---

## ✅ Done!

At the end of these milestones, the application will:
- Accept and validate CSV uploads
- Persist content in PostgreSQL
- Authenticate via Google OAuth
- Provide user- and admin-level file access
- Pass all tests and lint checks
- Be ready for future feature expansion
