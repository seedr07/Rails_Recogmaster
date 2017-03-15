require File.expand_path("../../../lib/local_config", __FILE__)
Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  config.eager_load = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like nginx, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.js_compressor = :uglifier
  config.assets.css_compressor = :sass

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Version of your assets, change this if you want to expire all your assets.
  config.assets.version = '1.0'

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # See everything in the log (default is :info)
  config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)
  # config.logger = Logger.new(config.paths["log"].first, 5, 524288000)#500Mb logs
  
  # Disable automatic flushing of the log to improve performance.
  # config.autoflush_log = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
  
  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  config.before_initialize do
    # config.action_controller.asset_host = "//#{Rails.configuration.credentials['aws']['bucket']}.s3.amazonaws.com"
    config.action_controller.asset_host = "//#{Rails.configuration.credentials['aws']['cloud_front']}"
    Recognize::Application.config.asset_host = config.action_controller.asset_host#make a shorter alias to this
    
    #point mailer assets to s3 so they can point to non-digest assets and not have to worry about caching
    config.action_mailer.asset_host = "http://#{Rails.configuration.credentials['aws']['bucket']}.s3.amazonaws.com"
  end
  
  # Disable delivery errors, bad email addresses will be ignored
  config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  config.host = "recognizeapp.com"
  config.send_push_notifications = false
  
  config.action_mailer.delivery_method   = :smtp

  config.before_initialize do 
    Recognize::Application.config.middleware.use ExceptionNotification::Rack,
      email: {
        :email_prefix => "[#{Recognize::Application.config.host}] ",
        :sender_address => "donotreply@recognizeapp.com",
        :exception_recipients => "peter@recognizeapp.com",
        :sections => %w(data request session backtrace environment),
        :background_sections => %w(data backtrace)
         
      }

    config.action_mailer.smtp_settings = {
      :address              => "smtp.mandrillapp.com",
      :port                 => 587,
      :user_name            => Rails.configuration.credentials['mandrill']['username'],
      :password             => Rails.configuration.credentials['mandrill']['password'],
      :authentication       => 'login',
      :enable_starttls_auto => true  }      
  end



  config.eager_load = true


end
