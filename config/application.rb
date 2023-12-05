require_relative 'boot'
require File.expand_path('../../lib/middleware/token_touch', __FILE__)


require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GlobalPresentationService
  class Application < Rails::Application
    config.middleware.delete Rack::Lock
    config.middleware.use TokenTouch

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins (ENV['EDO_CORS'] || '*')
        resource '*', :headers => :any, :methods => [:get, :post, :put, :delete, :options]
      end
    end

    # config.active_record.raise_in_transactional_callbacks = true

    config.autoload_paths += Dir["#{Rails.root}/app/interactors/**/"]

    config.filter_parameters << :password

    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore
    config.middleware.use Rack::ContentLength

    ActiveSupport::Cache::Store.logger = ActiveSupport::Logger.new("log/#{Rails.env}-cache.log")
  end
end
