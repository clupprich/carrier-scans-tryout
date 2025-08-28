source "https://rubygems.org"

ruby File.read(".ruby-version").strip

gem "rails", "~> 8.0.2"

# - Core
gem "fulfil_api", "~> 0.3.3" # A Ruby HTTP client to interact with the API endpoints of Fulfil.io [https://github.com/codeturebv/fulfil_api]
gem "sqlite3", "~> 2.7" # Use SQLite as the database for Active Record
gem "puma", ">= 5.0" # Use the Puma web server [https://github.com/puma/puma]
gem "sidekiq", "~> 8.0" # Simple, efficient background processing for Ruby. [https://github.com/sidekiq/sidekiq]

# - Frontend
gem "importmap-rails", "~> 2.2" # Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "propshaft", "~> 1.2" # The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "stimulus-rails", "~> 1.3" # Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "turbo-rails", "~> 2.0" # Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "dotenv", "~> 3.1" # Loads environment variables from `.env`. [https://github.com/bkeepers/dotenv]
  gem "brakeman", require: false # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "rubocop-minitest", "~> 0.38.1" # Automatic Minitest code style checking tool. [https://github.com/rubocop/rubocop-minitest]
  gem "rubocop-performance", "~> 1.25" # Automatic performance optimizations in Ruby code. [https://github.com/rubocop/rubocop-performance/]
  gem "rubocop-rails-omakase", require: false # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
end

group :development do
  gem "web-console" # Use console on exceptions pages [https://github.com/rails/web-console]
end

group :test do
  gem "capybara" # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "mocha", "~> 2.7" # Mocking and stubbing library with JMock/SchMock syntax. Used by the ShopifyApp gem's test helpers [https://github.com/freerange/mocha]
  gem "selenium-webdriver"
  gem "webmock", "~> 3.25" # WebMock allows stubbing HTTP requests. [https://github.com/bblimke/webmock]
end
