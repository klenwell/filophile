# Prompt 1: User Authentication

## Implementation Steps

1.  **Build Docker images:** I built the Docker images to ensure all dependencies from the `Gemfile` were installed.
    ```bash
    docker-compose build
    ```

2.  **Generate `User` model and migration:** I used a Rails generator to create the `User` model and its corresponding migration file.
    ```bash
    docker-compose run --rm web rails generate model User email:string:uniq name:string uid:string provider:string admin:boolean
    ```

3.  **Update `create_users` migration:** I modified the generated migration to add a `not null` constraint to the `email` column and set default values for the `provider` and `admin` columns.
    *   `db/migrate/20250624013252_create_users.rb`

4.  **Run database migrations:** I ran the migrations to apply the new `users` table schema to the database.
    ```bash
    docker-compose run --rm web rails db:migrate
    ```

5.  **Configure OmniAuth middleware:** I created an initializer file to configure the OmniAuth middleware with the Google OAuth2 provider.
    *   `config/initializers/omniauth.rb`

6.  **Add class method to `User` model:** I added the `from_omniauth` class method to the `User` model to handle finding or creating a user from the data returned by OmniAuth.
    *   `app/models/user.rb`

7.  **Set up authentication routes:** I updated the routes file to include the OmniAuth callback, a logout path, and a root path for the application.
    *   `config/routes.rb`

8.  **Create `SessionsController`:** I created a new controller to handle user sessions, with a `create` action for logging in and a `destroy` action for logging out.
    *   `app/controllers/sessions_controller.rb`

9.  **Enforce authentication globally:** I added a `before_action` to `ApplicationController` to require user authentication for all actions, along with a `current_user` helper method.
    *   `app/controllers/application_controller.rb`

10. **Write request specs for session logic:** I created a new request spec file to test the login and logout functionality, using a mocked OmniAuth response.
    *   `spec/requests/sessions_spec.rb`

11. **Run RSpec tests:** Finally, I ran the test suite to ensure that the entire authentication flow was working correctly.
    ```bash
    docker-compose run --rm -e RAILS_ENV=test web rspec
    ```
