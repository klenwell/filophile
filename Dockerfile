# Base stage for development and testing
FROM ruby:3.2.2 AS base

# Install system dependencies
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs

# Create a non-root user
RUN useradd -u 1000 -m app && \
    chown -R app:app /home/app

# Create and set ownership for the app directory
RUN mkdir /app && chown -R app:app /app

WORKDIR /app

# Add the gem bin path to the PATH
ENV PATH="/app/vendor/bundle/bin:/app/vendor/bundle/ruby/3.2.0/bin:${PATH}"

# Switch to non-root user
USER app

# Configure bundler to install gems to vendor/bundle
RUN bundle config set --local path 'vendor/bundle'

# Install all gems
COPY --chown=app:app Gemfile Gemfile.lock ./
RUN bundle install -j 4

# Copy the rest of the application
COPY --chown=app:app . .


# Production stage
FROM base AS production

# Set production environment
ENV RAILS_ENV=production
ENV RACK_ENV=production

# Copy only production gems from base stage
COPY --from=base --chown=app:app /usr/local/bundle/ /usr/local/bundle/

# Copy application code
COPY --chown=app:app . .

# Add a script to be executed every time the container starts
COPY --chown=app:app entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Start the main process
CMD ["rails", "server", "-b", "0.0.0.0"]
