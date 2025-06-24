# Prompt 1: User Authentication

## Commands Executed

1.  **Build Docker images:**
    ```bash
    docker-compose build
    ```

2.  **Generate User Model and Migration:**
    ```bash
    docker-compose run --rm web rails generate model User email:string:uniq name:string uid:string provider:string admin:boolean
    ```

3.  **Run Database Migrations:**
    ```bash
    docker-compose run --rm web rails db:migrate
    ```

4.  **Run RSpec Tests:**
    ```bash
    docker-compose run --rm -e RAILS_ENV=test web rspec
    ```
