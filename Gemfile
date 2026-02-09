source "https://rubygems.org"

gem "rails", "~> 7.2.0"
gem "rails-i18n", "~> 7.0.10"

# Server
gem "puma"
gem "syslog-logger"
gem "whenever", require: false

# Database
gem "pg"
gem "kaminari"
gem "type_scopes"

gem "bcrypt"
gem "rmagick"
gem "sixarm_ruby_unaccent"
gem "tolk"
gem "diffy"

# Services
gem "rorvswild"
gem "aws-sdk-s3"

# Frontend
gem "jbuilder"
gem "inline_svg"
gem "octicons_helper"
gem "sprockets-rails"
gem "uglifier"

# Fix uninitialized constant ActiveSupport::LoggerThreadSafeLevel::Logger
# Because concurrent-ruby 1.3.5 does not require "logger" anymore.
# It should be fixed after Rails 7.
gem "concurrent-ruby", "1.3.4"

# Standard gems not shipped anymore in Ruby
gem "bigdecimal"
gem "mutex_m"
gem "observer"
gem "syslog"
gem "csv"
gem "drb"

group :development, :test do
  gem "byebug"
  gem "dotenv-rails"
  gem "brakeman", require: false
  gem "standard"
end

group :development do
  gem "web-console"
  # Fix on MacOS : Library not loaded: /usr/local/opt/readline/lib/libreadline.6.dylib (LoadError)
  gem "rb-readline"
end

group :test do
  gem "mocha"
  gem "top_tests"
  gem "simplecov", require: false
  gem "minitest", "~> 5.22" # Minitest 6 is incompatible with Tails 7.0
end
