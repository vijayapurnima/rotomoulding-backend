source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.0'
# Use postgresql as the database for Active Record
gem 'pg'
# Use Puma as the app server
gem 'puma'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
# Use Redis adapter to run Action Cable in production
gem 'redis'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'
gem 'interactor'
gem 'interactor-rails'
gem 'sentry-raven'
gem 'health_check'
gem 'aws-sdk-ssm'
gem 'aws-sdk-elasticache'
gem 'pry-rails'

gem 'hiredis'
gem 'yajl-ruby'
gem 'aasm'
gem 'lograge' #Lograge replaces Rails' request logging entirely, reducing the output per request to a single line with all the important information
gem 'net-ssh-gateway' #SSH gateway for connecting to external API
gem 'sequel' #Sequel is a simple, flexible, and powerful SQL database access toolkit for Ruby.
gem 'savon' #Heavy metal SOAP client
gem 'rubyntlm' #Heavy metal SOAP client

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :test do
  gem 'webmock'
  gem 'mock_redis'
  gem 'mocha'
  gem 'rails-controller-testing'
end


group :development do
  gem 'yard'
end

gem 'multi_json'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
