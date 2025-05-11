source "https://rubygems.org"

ruby "3.3.1"
gem 'concurrent-ruby', '1.3.4'

# for photo upload
gem 'base64'

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# password degit 
gem 'bcrypt', '~> 3.1.7'

#device
gem 'devise'

#mutex
gem 'mutex_m'

#bigdecimal
gem 'bigdecimal'

# jwt
gem "devise-jwt"

# dotenv for sensitive information
gem 'dotenv-rails', groups: [:development, :test]



# seriliazer format json
gem "fast_jsonapi"

#encodein and decoding
gem 'jwt'

# for recurring transaction
gem 'ice_cube'

# middleware
gem "rack-cors"

# sql
gem 'mysql2'

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "7.0.8"

# Seed fu for maintain seed data
gem 'seed-fu', '~> 2.3', '>= 2.3.9'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# For Pagination
gem 'will_paginate', '~> 3.3'

# For repeated transactions (frequency)
gem 'whenever', require: false

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ]
  # test gem
  gem 'rspec-rails'
  # test simpler
  gem 'shoulda-matchers'
  # used to create test data
  gem 'factory_bot_rails'
  # for temporary email
  gem 'faker'
  # for clearing test data
  gem 'database_cleaner'
  # For test coverage
  gem 'simplecov'
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end
