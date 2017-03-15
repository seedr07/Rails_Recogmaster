source 'https://rubygems.org'

gem 'rails', '4.1.14'
gem 'net-ssh', '~> 2.7.0'

# rails 4 upgrade gems
gem 'protected_attributes'
gem 'rails-observers'
gem 'actionpack-page_caching'
gem 'actionpack-action_caching'
gem 'activerecord-deprecated_finders'
gem 'activerecord-session_store'
gem 'turbolinks'
gem 'nprogress-rails'
gem 'byebug'
gem 'sitemap_generator'

gem 'mysql2'
gem 'jquery-rails'
gem 'scrypt'
gem 'authlogic', github: 'binarylogic/authlogic'
#use the below if you get an authlogic error about not being able to connect to the database.  
#so enable line, run migrations or whatever you need to do, but then don't forget to change back!
#it should go away after migrating
#gem 'authlogic', :git => 'git://github.com/james2m/authlogic.git', :branch => 'fix-migrations'
# gem 'exception_notification'
gem 'exception_notification', git: 'git://github.com/smartinez87/exception_notification.git'
gem 'rails-i18n'
gem 'pusher'
gem 'declarative_authorization'
gem 'carrierwave', '~> 0.10.0'
gem 'mini_magick'
gem 'bourbon'
gem 'domainatrix'
gem 'ios-checkboxes', github: "planetio/ios-checkboxes"
gem 'will_paginate'
gem "delayed_job_active_record", :github => "collectiveidea/delayed_job_active_record"
gem "delayed_job", :github => "collectiveidea/delayed_job"
gem 'fog'
gem 'omniauth'
gem 'omniauth-yammer'
gem "omniauth-google-oauth2"
gem 'omniauth-office365'
gem 'gdata_19', require: 'gdata'
gem 'yam', '~> 2.2.0', require: 'yammer'
# gem 'mail_jack', path: '/Users/pete/work/mail_jack'
gem 'mail_jack', git: 'git@github.com:synth/mail_jack.git'
gem 'whenever', require: false
gem 'redis'
gem 'stripe', :git => 'https://github.com/stripe/stripe-ruby'
gem 'colorize'
# gem 'seahorse', path: '/Users/pete/work/seahorse'
gem 'unicorn'
gem 'rack-cors', :require => 'rack/cors'
gem 'hashie', '>= 3.2.0'
# gem 'rango', path: '/Users/pete/work/rango'
gem 'rango', github: 'planetio/rango'
gem 'geocoder'
gem 'activerecord-import'
gem 'analytics-ruby', '~> 2.0.0', :require => 'segment/analytics'
gem 'twilio-ruby'
gem 'ruby-saml','~> 1.1.2'

#need access to factory in main block because we use it in a rake task
#that may need to be run on heroku and heroku doesn't install dev/test gems
gem 'factory_girl'
gem 'factory_girl_rails'

gem 'timecop' #make available to production env so we can run reminder simulations...
gem "jquery-fileupload-rails", github: "cipacda/jquery-fileupload-rails"
gem 'paranoia'
gem 'daemons', github: 'thuehlinger/daemons'
gem 'hashids'
gem 'wisper'
# gem 'wisper-celluloid'

#need this in all :assets, :production so that we can run the asset:sync task in production
# gem 'asset_sync', git: "git://github.com/rumblelabs/asset_sync.git", ref: "fefd9ddfa1b609eb39f6003d91dc52acf405a3e4", groups: [:assets, :production]
# gem 'rack-mini-profiler', groups: [:development]
# gem 'ruby-prof', groups: [:development]
gem 'sanitize_email'
gem 'postmark-rails'
gem 'active_model_serializers'
gem 'mandrill-api'
gem 'slackistrano', require: false
gem 'slack-ruby-client'

gem 'pry'
gem 'pry-remote'
gem 'pry-nav'
gem 'pry-rails'
gem 'pry-stack_explorer'

gem 'closeio'

# old api
gem 'rails-api', github: 'rails-api/rails-api'
gem 'seahorse', github: 'planetio/seahorse'

# new api
gem 'doorkeeper'
gem 'grape'
gem 'grape-route-helpers'
gem 'grape-swagger', github: 'synth/grape-swagger', branch: 'hide-module-from-path'#path: '/Users/pete/work/grape-swagger'
gem 'grape-entity'
gem 'wine_bouncer', github: 'antek-drzewiecki/wine_bouncer'
gem 'api-pagination'
gem 'redcarpet'
gem 'rouge'

group :development, :test do
  gem 'phantomjs', '1.9.7.1'
  gem 'jasmine-rails'
  gem 'rspec'
  gem 'rspec-core'
  gem 'rspec-rails'
  gem 'launchy'
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'capybara-screenshot'
  gem 'selenium-webdriver', '2.47.1'
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'awesome_print'
  gem 'spring'
  gem "spring-commands-rspec"  

  #For most systems:
  # gem 'libv8', '~> 3.11.8.12', :platforms => :ruby
  # gem 'therubyracer', '~> 0.11.3', :require => 'v8', :platforms => :ruby

  #Possibly needed for some Mountain Lion Systems - "darwin12.2.0"
  # gem 'libv8', '~> 3.11.8'  
  # gem 'therubyracer', '0.11.0beta5'
  
  gem 'simplecov', require: false
  gem 'memory_test_fix'
  gem 'bullet'
  gem 'brakeman', require: false
  gem 'headless'
  # gem 'psych', '~> 1.3.4' # if problems with psych, use this version
  gem 'psych', '~> 2.0.4'
  gem 'typhoeus', '~> 1.0.1'
  
  gem 'rack_session_access'
  gem 'puma'
  gem 'grape-rails-routes'
end

group :development do 
  gem 'capistrano', '~> 3.0', require: false
  gem 'capistrano-rails', '~> 1.1', require: false
  gem 'capistrano-bundler', '~> 1.1', require: false
  # gem 'rvm1-capistrano3', require: false
  gem 'capistrano-rvm', require: false
  gem 'capistrano-passenger', require: false
  gem 'capistrano3-delayed-job', '~> 1.0', require: false
  gem 'capistrano-newrelic', require: false
  gem "capistrano-db-tasks", github: "planetio/capistrano-db-tasks", require: false
  gem 'capistrano-pending', :require => false
  gem 'capistrano-github-releases', require: false, github: "synth/capistrano-github-releases"
  # gem 'capistrano-github-releases', require: false, path: '/Users/pete/work/capistrano-github-releases'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'test-unit'
  gem 'quiet_assets'
  gem 'solano'
  gem 'travis'
end

group :production do 
  gem 'thin' 
  gem 'mysql'
end


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 4.0.3'
  gem 'uglifier'
end

group :assets, :development, :test do
  gem 'therubyracer'
end



