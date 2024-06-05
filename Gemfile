source "https://rubygems.org"

ruby "3.2.3"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# seriliazer format json
gem "fast_jsonapi"

#encodein and decoding
gem 'jwt'

#device
gem 'devise'

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

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ]
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

