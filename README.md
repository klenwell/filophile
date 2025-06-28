# filophile

## Getting Started with Docker

This project is configured to run in a Docker container. The following instructions will help you get the application and its dependencies up and running.

### Prerequisites

*   [Docker](httpss://www.docker.com/get-started)
*   [Docker Compose](httpss://docs.docker.com/compose/install/)

### Initial Setup

Before running the application for the first time, you need to build the Docker image and set up the databases.

1.  **Build the Docker image:**

    ```bash
    docker-compose build
    ```

2.  **Create and migrate the development and test databases:**

    ```bash
    docker-compose run web rails db:setup
    docker-compose run test rails db:setup
    ```

### Configuration

Before you can run the web server, you need to configure Google OAuth 2.0 for authentication.

1.  **Create Google OAuth Credentials:**
    - Go to the [Google Cloud Console](https://console.cloud.google.com/).
    - Create a new project or select an existing one.
    - Navigate to "APIs & Services" > "Credentials".
    - Click "Create Credentials" and select "OAuth client ID".
    - Choose "Web application" as the application type.
    - Under "Authorized JavaScript origins", add `http://localhost:3000`.
    - Under "Authorized redirect URIs", add `http://localhost:3000/auth/google_oauth2/callback`.
    - Click "Create" and copy the **Client ID** and **Client Secret**.

2.  **Update Docker Compose Configuration:**
    - Open the `docker-compose.yml` file.
    - In the `web` service's `environment` section, you will find placeholders for `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET`.
    - Replace `"YOUR_GOOGLE_CLIENT_ID"` and `"YOUR_GOOGLE_CLIENT_SECRET"` with the credentials you obtained from the Google Cloud Console.

### Running the Web Server

Once you have configured your OAuth credentials, you can start the web server.

```bash
docker-compose up --build
```

You can then access the application at [http://localhost:3000](http://localhost:3000).

To run the server in the background (detached mode), use:

```bash
docker-compose up -d web
```

### Running Tests

You can run the entire test suite using the `test` service defined in the `docker-compose.yml` file.

**Run all specs:**

```bash
docker-compose run test
```

**Run a single spec file:**

To run specs for a specific file, pass the file path as an argument to the `rspec` command. For example:

```bash
docker-compose run test bundle exec rspec spec/models/user_spec.rb
```
