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

WORKDIR /app

# Switch to non-root user
USER app

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
