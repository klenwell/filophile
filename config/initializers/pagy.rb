# frozen_string_literal: true

# Pagy initializer file
# See https://ddnexus.github.io/pagy/docs/extras/bootstrap

# Load the bootstrap extra
require "pagy/extras/bootstrap"

# Set the default number of items per page
Pagy::DEFAULT[:items] = 10
