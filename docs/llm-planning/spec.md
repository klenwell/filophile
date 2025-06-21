# File Uploader Specification

## Product Overview

This is a business-to-business (B2B) web application that allows users to upload, validate, and manage CSV data files. The application will:

- Accept file uploads from authenticated users.
- Validate files for correct structure and duplication.
- Store validated data in a relational database.
- Allow users to view and download their own uploaded files.
- Allow administrators to view all uploaded files and their details.
- Authenticate users via Google OAuth.
- Provide a basic UI with an upload form.
- Be developed using Ruby on Rails (latest stable version) and PostgreSQL.
- Be containerized for local development using Docker.
- Include full test coverage with RSpec following [Even Better Specs](https://evenbetterspecs.github.io/).

---

## Functional Requirements

### User Authentication

- Users can sign in with their Google account (OAuth).
- Only authenticated users can access any part of the app.
- Admins are flagged via an internal user attribute (`admin: boolean`).
- A user’s session persists securely using encrypted cookies.

### File Upload and Validation

- Authenticated users can upload CSV files via a browser form.
- The system performs validations:
  - File must be a valid CSV (based on MIME type and extension).
  - Each row must have the same number of columns.
  - Column count must be greater than zero.
  - Duplicate file detection is based on a hash (e.g., SHA256) of normalized contents.
- If validations fail, the user is presented with clear error messages.
- If successful:
  - File metadata is saved.
  - File contents are parsed and stored in the database.
  - File hash is recorded to detect future duplicates.
  - Original file is stored (e.g., on disk or in a blob column) for future download.

### File Management

- Users can view a list of files they have uploaded.
- Users can view a detailed page for each upload with metadata and a preview of parsed contents.
- Users can download a copy of their uploaded files.
- Admins can view:
  - A paginated list of all uploads across the system.
  - Any individual file and its metadata + contents.
- Users can only see and access their own uploads.
- Admins can see all uploads, regardless of owner.

---

## Data Model

### `User`

| Field      | Type      | Notes                          |
|------------|-----------|--------------------------------|
| id         | integer   | Primary key                    |
| email      | string    | Unique                         |
| name       | string    |                                |
| uid        | string    | From Google OAuth              |
| provider   | string    | Default: `"google_oauth2"`     |
| admin      | boolean   | Default: `false`               |
| timestamps | datetime  | `created_at`, `updated_at`     |

### `Upload`

| Field         | Type      | Notes                           |
|---------------|-----------|---------------------------------|
| id            | integer   | Primary key                     |
| user_id       | integer   | Foreign key to `User`           |
| filename      | string    | Original uploaded filename      |
| content_hash  | string    | SHA256 (unique constraint)      |
| row_count     | integer   | Total rows in CSV               |
| column_count  | integer   | Number of columns per row       |
| uploaded_at   | datetime  | When the upload occurred        |
| original_file | blob/path | Stored for re-download          |
| timestamps    | datetime  | `created_at`, `updated_at`      |

### `UploadRow`

| Field      | Type     | Notes                       |
|------------|----------|-----------------------------|
| id         | integer  | Primary key                 |
| upload_id  | integer  | Foreign key to `Upload`     |
| row_index  | integer  | Position in file (0-based)  |
| values     | JSON     | Array of string values      |
| timestamps | datetime | `created_at`, `updated_at`  |

---

## API Endpoints (draft)

### User Routes

- `GET /dashboard` – Lists user’s uploaded files
- `POST /uploads` – Upload a new CSV file
- `GET /uploads/:id` – View metadata and contents of a file
- `GET /uploads/:id/download` – Download original file
- `DELETE /uploads/:id` – Delete file (optional)

### Admin Routes

- `GET /admin/uploads` – List all uploads across users
- `GET /admin/uploads/:id` – View file details and contents

---

## UI

- Basic Bootstrap-style layout
- Google OAuth login button
- Upload form (drag-drop or file picker)
- Client-side file type checking (CSV-only)
- Error messages on failed validation
- Table of uploaded files with:
  - Filename
  - Uploaded at
  - Row and column count
  - Download link
- Admin view with:
  - User filtering
  - Access to all uploads

---

## Development Environment

- Ruby on Rails (latest stable version)
- PostgreSQL
- Docker + docker-compose for local development
- OAuth via `omniauth-google-oauth2`
- Test stack:
  - RSpec
  - FactoryBot
  - (Optional: Guard, RuboCop, Spring)

---

## Testing

- Full test coverage using RSpec.
- Models, controllers, and services are all tested.
- Coverage includes:
  - Google OAuth auth flow
  - File validation (malformed, empty, duplicate, oversize)
  - Upload success/failure paths
  - Role-based access control
  - Data persistence and correctness
- Tests follow [Even Better Specs](https://evenbetterspecs.github.io/) style:
  - Clear `describe`, `context`, `it` structure
  - Use of `let`, `subject`, `before`
  - Factory-based model instantiation

---

## Assumptions

- All CSV values treated as strings (no type inference).
- Max file size: ~10,000 rows or ~5MB.
- CSV encoding must be UTF-8.
- File storage is ephemeral; long-term persistence happens via parsed content in DB.
- No background jobs or async workers in v1.
- No JavaScript framework (e.g., React) is used in v1.

---

## Non-Goals

- No support for Excel or other non-CSV formats in v1.
- No per-column validation or schema inference.
- No email notifications, user profiles, or dashboards.
- No file versioning or rollback capability.
- No multi-user upload collaboration.
