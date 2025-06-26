# Milestone 2.1: Generate Upload and UploadRow Models

This document outlines the steps taken to generate the `Upload` and `UploadRow` models, including their associations, validations, and full model specs.

## Summary of Work

1.  **Model Generation**: Generated `Upload` and `UploadRow` models using Rails generators within the Docker environment.
2.  **Database Migrations**: Created and ran migrations to add the `uploads` and `upload_rows` tables to the database schema.
3.  **Active Storage**: Installed and configured Active Storage to handle file uploads, adding the necessary tables.
4.  **Model Configuration**: Added `has_many`, `belongs_to`, and `has_one_attached` associations to the `User`, `Upload`, and `UploadRow` models. Implemented validations for presence, numericality, and uniqueness.
5.  **Testing**: Wrote comprehensive model specs using RSpec and Shoulda Matchers. Created factories with realistic data using FactoryBot and Faker.
6.  **Debugging**: Diagnosed and fixed issues related to the Docker environment, `shoulda-matchers` configuration, and Faker gem usage.

## Terminal Commands

The following commands were executed to complete the task. Note that initial commands failed due to issues with the local environment vs. the project's Dockerized setup. The successful commands are listed below.

```bash
# Generate the Upload model
docker-compose run --rm web bin/rails g model Upload user:references filename:string content_hash:string:uniq row_count:integer column_count:integer uploaded_at:datetime

# Generate the UploadRow model
docker-compose run --rm web bin/rails g model UploadRow upload:references row_index:integer values:json

# Run the initial database migrations
docker-compose run --rm web bin/rails db:migrate

# Install Active Storage
docker-compose run --rm web bin/rails active_storage:install

# Run the Active Storage migration
docker-compose run --rm web bin/rails db:migrate

# Run the model specs (initial run failed, final run passed)
docker-compose run --rm test bundle exec rspec spec/models/upload_spec.rb spec/models/upload_row_spec.rb
```

## File Modifications

The following files were created or modified.

### `app/models/user.rb`

```ruby
class User < ApplicationRecord
  has_many :uploads, dependent: :destroy

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.name = auth.info.name
      user.uid = auth.uid
    end
  end
end
```

### `app/models/upload.rb`

```ruby
class Upload < ApplicationRecord
  belongs_to :user
  has_many :upload_rows, dependent: :destroy
  has_one_attached :original_file

  validates :filename, presence: true
  validates :content_hash, presence: true, uniqueness: true
  validates :row_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :column_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :uploaded_at, presence: true
end
```

### `app/models/upload_row.rb`

```ruby
class UploadRow < ApplicationRecord
  belongs_to :upload

  validates :row_index, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :values, presence: true
end
```

### `spec/rails_helper.rb`

```ruby
# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'capybara/rspec'
require 'database_cleaner/active_record'
require 'shoulda/matchers'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://rspec.info/features/6-0/rspec-rails
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # Factory Bot configuration
  config.include FactoryBot::Syntax::Methods

  # Database Cleaner configuration
  config.before(:suite) do
    # Allow cleaning when using Docker database URL
    DatabaseCleaner.allow_remote_database_url = true

    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
```

### `spec/factories/uploads.rb`

```ruby
FactoryBot.define do
  factory :upload do
    association :user
    filename { Faker::File.file_name(dir: 'uploads') }
    content_hash { Digest::SHA256.hexdigest(Faker::Lorem.sentence) }
    row_count { Faker::Number.between(from: 1, to: 1000) }
    column_count { Faker::Number.between(from: 1, to: 100) }
    uploaded_at { Time.current }
  end
end
```

### `spec/factories/upload_rows.rb`

```ruby
FactoryBot.define do
  factory :upload_row do
    association :upload
    row_index { Faker::Number.number(digits: 2) }
    values { Array.new(5) { Faker::Lorem.word } }
  end
end
```

### `spec/models/upload_spec.rb`

```ruby
require 'rails_helper'

RSpec.describe Upload, type: :model do
  let(:user) { create(:user) }

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:upload_rows).dependent(:destroy) }

    it 'has one attached original_file' do
      upload = Upload.new
      expect(upload).to respond_to(:original_file)
    end
  end

  describe 'validations' do
    subject { create(:upload, user: user) }

    it { should validate_presence_of(:filename) }
    it { should validate_presence_of(:content_hash) }
    it { should validate_uniqueness_of(:content_hash) }
    it { should validate_presence_of(:row_count) }
    it { should validate_numericality_of(:row_count).only_integer.is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:column_count) }
    it { should validate_numericality_of(:column_count).only_integer.is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:uploaded_at) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:upload, user: user)).to be_valid
    end
  end
end
```

### `spec/models/upload_row_spec.rb`

```ruby
require 'rails_helper'

RSpec.describe UploadRow, type: :model do
  describe 'associations' do
    it { should belong_to(:upload) }
  end

  describe 'validations' do
    it { should validate_presence_of(:row_index) }
    it { should validate_numericality_of(:row_index).only_integer.is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:values) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:upload_row)).to be_valid
    end
  end
end
