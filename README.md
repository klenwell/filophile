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

### Running the Web Server

To start the web server for local development, run the following command:

```bash
docker-compose up web
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
