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
