# frozen_string_literal: false

source 'https://rubygems.org'
ruby '2.5.3'

# APPLICATION LAYER
  # Web application related
gem 'rack', '~> 2.0.6'
gem 'econfig', '~> 2.1'
gem 'puma', '~> 3.11'
gem 'roda', '~> 3.8'
gem 'rack-cache', '~> 1.8'
gem 'redis', '~> 4.0'
gem 'redis-rack-cache', '~> 2.0'

  # Controllers and services
gem 'dry-monads'
gem 'dry-transaction'
gem 'dry-validation'

# PRESENTATION LAYER
gem 'multi_json'
gem 'roar'

# DOMAIN LAYER
gem 'dry-struct', '~> 0.5'
gem 'dry-types', '~> 0.5'

# INFRASTRUCTURE LAYER
  # Networking gems
gem "httparty"
gem 'http', '~> 3.0'

  # Queues
gem 'aws-sdk-sqs', '~>1'

  # Database
gem 'hirb', '~> 0.7'
gem 'sequel', '~> 5.13'

group :development, :test do
  gem 'database_cleaner'
  gem 'sqlite3'
end

group :production do
   gem 'pg', '~> 0.18'
end

 # WORKERS
gem 'shoryuken', '~>4'
gem 'faye', '~>1'

# DEBUGGING
group :development, :test do
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
end


# TESTING
group :test do
  gem 'minitest', '~> 5.11'
  gem 'minitest-rg', '~> 5.2'
  gem 'simplecov', '~> 0.16'
  gem 'vcr', '~> 4.0'
  gem 'webmock'
end
gem 'rack-test' # can also be used to diagnose production

# QUALITY
group :development, :test do
  gem 'flog'
  gem 'reek'
  gem 'rubocop'
end

# UTILITIES
gem 'rake', '~> 12.3'
gem 'pry'
gem 'solargraph'
gem 'travis'

group :development, :test do
  gem 'rerun', '~> 0.13'
end

