Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false
  
  # For mailcatcher
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = { :address => "localhost", :port => 1025 } 

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Do not compress assets
  config.assets.compress = false
  
  # Checks for improperly declared sprockets dependencies.
  config.assets.raise_runtime_errors = true

  # Expands the lines which load the assets
  config.assets.debug = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.host = "localhost:3000"
  # config.asset_host = "//"+config.host
    
  config.send_push_notifications = false

  config.logger = Logger.new(config.paths["log"].first, 1, 104857600)

  config.before_initialize do 
    Recognize::Application.config.middleware.use ExceptionNotification::Rack,
      email: {
        :email_prefix => "[#{Recognize::Application.config.host}] ",
        :sender_address => "donotreply@recognizeapp.com",
        :exception_recipients => "devexceptions@recognizeapp.com", # doesnt matter as it goes to mailcatcher... 
        :sections => %w(data request session backtrace environment),
        :background_sections => %w(data backtrace)
      }
    # config.action_mailer.smtp_settings = {
    #   :address              => "smtp.mandrillapp.com",
    #   :port                 => 587,
    #   :user_name            => Rails.configuration.credentials['mandrill']['username'],
    #   :password             => Rails.configuration.credentials['mandrill']['password'],
    #   :authentication       => 'login',
    #   :domain               => Recognize::Application.config.host,
    #   :enable_starttls_auto => true  }      
  end
  config.after_initialize do
    #enable Bullet for n+1 query checking
    Bullet.enable = false
    Bullet.alert = false 
    Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.rails_logger = true
  end
  
  BetterErrors.editor = :sublime

  config.eager_load = false

  config.quiet_assets_paths << '.*/development/avatar_attachment.*'
  config.quiet_assets_paths << '.*/development/badge.*'
end
