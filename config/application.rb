require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module App
  class Application < Rails::Application
    config.load_defaults 7.0
    config.api_only = true
    config.autoload_paths << Rails.root.join('app/services')
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local
    config.i18n.default_locale = :ja
    config.hosts << "be-happy-back.fly.dev"
    config.middleware.delete ActionDispatch::Session::CookieStore
    config.middleware.delete ActionDispatch::Cookies
    config.middleware.delete ActionDispatch::Flash
    config.middleware.delete Rack::MethodOverride
  end
end
