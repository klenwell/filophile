# spec.md

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

## Functional Requirements

### User Authentication

- Users can sign in with their Google account (OAuth).
- Only authenticated users can access any part of the app.
- Admins are flagged via an internal user attribute (`admin: boolean`).

### File Upload and Validation

- Authenticated users can upload CSV files.
- The system performs validations:
  - Each row in the CSV must have the same number of columns.
  - Duplicate file detection is based on hash of contents.
- If validations fail, user is presented with an error message.
- If successful:
  - File metadata is saved.
  - File contents are parsed and stored.
  - File hash is recorded to detect future duplicates.

### File Management

- Users can view a list of files they have uploaded.
- Users can download a copy of their previously uploaded files.
- Admins can view:
  - All files uploaded across the system.
  - Any individual file and its details (metadata + contents).
- Users can only see and access their own uploads.

## Data Model

### User

- id
- email
- name
- uid (from Google OAuth)
- provider (default: "google_oauth2")
- admin (boolean)
- timestamps

### Upload

- id
- user_id (foreign key)
- filename
- content_hash (SHA256 or similar)
- row_count
- column_count
- uploaded_at
- timestamps

### UploadRow

- id
- upload_id (foreign key)
- row_index (integer)
- values (JSON)
- timestamps

## API Endpoints (non-final, subject to Rails routing)

### User Routes

- `GET /dashboard` – lists user’s uploaded files
- `POST /uploads` – upload a new CSV file
- `GET /uploads/:id` – view metadata and contents of a file
- `GET /uploads/:id/download` – download file

### Admin Routes

- `GET /admin/uploads` – list all uploads across users
- `GET /admin/uploads/:id` – view file details and contents

## UI

- Basic Bootstrap-style layout
- Google OAuth login button
- Upload form (drag-drop or file picker)
- Error messages on failed validation
- Table of uploaded files with:
  - Filename
  - Uploaded at
  - Row + column count
  - Download link
- Admin view with similar layout but extended permissions

## Development Environment

- Ruby on Rails (latest stable version)
- PostgreSQL
- Docker + docker-compose for local development
- RSpec + FactoryBot + Shoulda Matchers for tests
- OAuth via `omniauth-google-oauth2`

## Testing

- All models, controllers, and services will be tested.
- RSpec used for both unit and integration tests.
- Test coverage includes:
  - User auth
  - File upload and validation
  - Duplicate detection
  - Permission enforcement (user vs admin)
  - Data persistence and integrity
- Tests follow Even Better Specs structure:
  - `describe`, `context`, `it` blocks
  - Clear use of let, subject, and setup blocks
  - Factories for all models

## Assumptions

- CSV values will be treated as strings (no data type inference in v1).
- Maximum upload size is ~10k rows per file.
- Files will be stored temporarily for re-download but contents are persisted in DB.
- No background jobs or async processing required for v1.
- No front-end JS frameworks (e.g. React) are planned for v1.

## Non-Goals

- No support for Excel files or other formats in v1.
- No custom data normalization or schema inference beyond column consistency.
- No email notifications or user management interface in v1.
