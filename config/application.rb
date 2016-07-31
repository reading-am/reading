require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Reading
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Change default header to allow framing else user overlays won't work
    # TODO - change to prevent clickjacking
    # ref: http://edgeguides.rubyonrails.org/security.html#default-headers
    config.action_dispatch.default_headers['X-Frame-Options'] = 'ALLOWALL'

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib/modules)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
    config.active_record.observers = :authorization_observer, :relationship_observer, :blockage_observer, :comment_observer, :page_observer

    config.active_job.queue_adapter = :sidekiq
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.enforce_available_locales = true
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Enable the asset pipeline
    # Even though this is true by default for Rails 4, something is
    # overwriting it unless set here. Maybe requirejs?
    # Similar issues: https://github.com/rails/rails/issues/10334
    config.assets.enabled = true

    # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
    config.assets.precompile += ['*.css*','bookmarklet/loader.js']

    # per: https://github.com/jwhitley/requirejs-rails/#build-time-asset-filter
    # name change: https://github.com/jwhitley/requirejs-rails/issues/229
    config.requirejs.logical_path_patterns += [/\.mustache$/,/\.css$/]

    config.cache_store = :dalli_store
  end
end
