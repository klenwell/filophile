# Project Specification: Data Uploader Service (B2B)

## 1. Introduction

This document outlines the requirements for a web-based service designed to allow business users to upload arbitrary data files, primarily in CSV format. The service will extract, normalize, and store the data in a database, providing functionalities for users to manage their uploads and for administrators to oversee the system.

## 2. Technology Stack

* **Framework:** Ruby on Rails (latest stable version)
* **Database:** PostgreSQL
* **Containerization:** Docker for local development environment
* **Testing:** RSpec, adhering to Even Better Specs guidelines

## 3. Core Functionality

### 3.1 File Upload

* **User Interface:** A simple web form will be provided for users to select and upload a single CSV file.
* **File Type Restriction:** The system will primarily accept CSV files.
* **File Size Limit:** Assume largest files may be up to 10,000 rows.

### 3.2 Data Extraction & Storage

* **Extraction:** The system will extract data from the uploaded CSV file.
* **Normalization (V1):** For version 1, all extracted values will be treated and stored as strings. The database schema should be designed to be flexible enough to accommodate varying CSV structures uniformly (e.g., a key-value store or a flexible JSONB column per row, or a generic `UploadedDataRow` model with dynamic attribute handling).
* **Storage:** The contents of valid, successfully uploaded files will be stored in the PostgreSQL database. The original file content should also be stored for download purposes (e.g., as a binary blob or by reference to a file storage system if necessary, but for V1, storing in DB is acceptable).

### 3.3 File Validation

The system will perform the following validations on uploaded files:

* **Format Consistency:**
    * The system will check for a consistent number of columns across all rows within the CSV file. If the number of columns varies, the file will be flagged as invalid.
* **Duplicate Detection:**
    * A file will be identified as a duplicate if its *content* (based on a hash of the file's content) matches a file already successfully uploaded to the system by any user.
* **User Feedback:** If a validation issue is detected, the website will display a clear warning message to the user, explaining the specific issue (e.g., "Inconsistent number of columns" or "This file content has already been uploaded").

### 3.4 Data Processing & Error Handling

* **Transformation (V1):** No complex data transformations beyond treating all values as strings are required for V1.
* **Error Reporting:** Any errors encountered during file processing (e.g., parsing issues, database write failures) will be logged by the system. User-facing error messages should be generic for V1, indicating a processing failure.

## 4. User Features

### 4.1 User Authentication & Authorization

* **Authentication:** Users will authenticate using OAuth, specifically by logging in with their Google account.
* **User Roles:** Two primary roles will exist: `User` and `Admin`.
* **Authorization:**
    * **User:** Can only access and manage files they have personally uploaded.
    * **Admin:** Can access and manage all files uploaded by any user.

### 4.2 File Management (User)

* **View Uploaded Files:** Users will be able to review a list of all files they have successfully uploaded. This list should include basic metadata (e.g., filename, upload date, status).
* **Download File:** Users will be able to download a copy of any file they have previously uploaded. The downloaded file should be identical to the original uploaded content.

## 5. Administration Features

### 5.1 File Management (Admin)

* **View Recent Uploads:** Administrators will have access to a dashboard or page displaying a list of recently uploaded files by all users.
* **View All Uploads:** Administrators will be able to view a comprehensive list of all files ever uploaded to the system by any user.
* **View File Details:** Administrators will be able to view detailed information for any specific uploaded file, including its content, metadata, and associated user.
* **Download File:** Administrators will be able to download a copy of any file uploaded by any user.

## 6. Development & Deployment

* **Local Development:** The local development environment will be fully containerized using Docker, ensuring consistency across development machines.
* **Code Generation Strategy:** This project will follow a three-step code generation strategy, where this `spec.md` will inform the generation of an `implementation.md` document, which in turn will guide the systematic generation of code.

## 7. Testing

* **Unit Tests:** Comprehensive unit tests will be written for all core functionalities, including models, services, and controllers.
* **Integration Tests:** Integration tests will cover key user flows, such as file upload, validation, and file review.
* **Framework:** All tests will be written using RSpec.
* **Guidelines:** Tests will adhere to the "Even Better Specs" guidelines ([https://evenbetterspecs.github.io/](https://evenbetterspecs.github.io/)).

## 8. Future Considerations (Out of Scope for V1)

* Advanced data type conversions (e.g., integer, float, date parsing)
* User-defined data transformations or mapping
* More sophisticated error handling and notification mechanisms (e.g., email alerts)
* Support for other file formats (e.g., Excel, JSON)
* Bulk file uploads
* Data visualization or reporting features
* API for programmatic uploads
