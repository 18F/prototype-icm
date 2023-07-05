source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.0"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.5"

gem "sprockets-rails" # Asset pipeline
gem "pg", "~> 1.1" # Postgres database

# Oracle database and client
gem "activerecord-oracle_enhanced-adapter", "~> 7.0.0"
gem "ruby-oci8"

gem "mustache" # Templates

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "standard" # Linting

  gem "cucumber-rails", require: false # Feature tests
  gem "test-unit" # Assertions for feature tests
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
end

group :test do
  gem "database_cleaner"
end
