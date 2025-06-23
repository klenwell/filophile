# Step 1.1: Initial Rails Setup with Docker

This document provides the steps to set up the initial Rails application with Docker.

## Setup Commands

```bash
# Create Docker configuration files
cat > Dockerfile << 'EOF'
FROM ruby:3.2.2

# Install system dependencies
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    npm

# Install yarn
RUN npm install -g yarn

# Create a non-root user with UID 1000 (typical first user on Linux)
RUN useradd -u 1000 -m app && \
    chown -R app:app /home/app

# Set working directory and ownership
WORKDIR /app
RUN chown app:app /app

# Switch to non-root user
USER app

# Copy Gemfile and install dependencies
COPY --chown=app:app Gemfile Gemfile.lock ./
RUN bundle install

# Copy the rest of the application
COPY --chown=app:app . .

# Add a script to be executed every time the container starts
COPY --chown=app:app entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Start the main process
CMD ["rails", "server", "-b", "0.0.0.0"]
EOF

cat > docker-compose.yml << 'EOF'
version: "3"
services:
  db:
    image: postgres:14
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: password
      POSTGRES_USER: filophile
      POSTGRES_DB: filophile_development
    ports:
      - "5432:5432"

  web:
    build: .
    command: bash -c "rm -f tmp/pids/server.pid && bundle exec rails s -p 3000 -b '0.0.0.0'"
    volumes:
      - .:/app
      - bundle_cache:/usr/local/bundle
    ports:
      - "3000:3000"
    environment:
      DATABASE_URL: postgres://filophile:password@db:5432/filophile_development
      RAILS_ENV: development
    depends_on:
      - db

volumes:
  postgres_data:
  bundle_cache:
EOF

cat > entrypoint.sh << 'EOF'
#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /app/tmp/pids/server.pid

# Then exec the container's main process
exec "$@"
EOF

chmod +x entrypoint.sh

# Create initial Gemfile
cat > Gemfile << 'EOF'
source "https://rubygems.org"

ruby "3.2.2"

# Rails itself
gem "rails", "~> 7.1.2"
gem "pg", "~> 1.1"
gem "puma", "~> 6.0"

# Asset pipeline
gem "sprockets-rails"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"

# Other defaults
gem "jbuilder"
gem "redis", "~> 4.0"
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
gem "bootsnap", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem "rspec-rails", "~> 6.0"
  gem "factory_bot_rails"
  gem "faker"
  gem "pry-rails"
end

group :development do
  gem "web-console"
  gem "rack-mini-profiler"
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "guard"
  gem "guard-rspec"
  gem "spring"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
  gem "shoulda-matchers"
  gem "database_cleaner-active_record"
end
EOF

touch Gemfile.lock

# Create Rails app and install dependencies
docker-compose run --rm web rails new . --force --database=postgresql --skip-git

# Fix permissions for Docker
sudo chown -R 1000:1000 .

# Remove default test directory (using RSpec instead)
rm -rf test/

# Install RSpec
docker-compose run --rm web rails generate rspec:install
```

## Next Steps

1. Set up the health check endpoint
2. Configure RuboCop
3. Set up Guard for automated testing
4. Add initial models and database schema

## Notes

- The application uses Ruby 3.2.2 and Rails 7.1.2
- PostgreSQL 14 is used as the database
- All development/test gems are configured in the Gemfile
- Docker is set up to run the application as a non-root user
- RSpec is configured as the testing framework
