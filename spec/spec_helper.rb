require 'rubygems'
require 'simplecov'

# SimpleCov.start 'rails' do
#   add_filter "/spec"
# end

def init_db!
  UserRole.where("user_id <> #{User.system_user.id}").delete_all
  User.unscoped.where("email <> 'app@recognizeapp.com'").delete_all
  Company.where("domain <> 'recognizeapp.com'").delete_all
end

def tables_not_to_truncate
  %w[roles badges users user_roles companies plans]
end

def ssi
  screenshot_and_open_image
end


ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'
require 'capybara-screenshot/rspec'
require 'authlogic/test_case'
require "rack_session_access/capybara"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

RSpec.configure do |config|

  config.mock_with :rspec
  config.use_transactional_fixtures = false
  config.use_instantiated_fixtures = false
  config.include RSpec::Rails::RequestExampleGroup, type: :request, file_path: /spec\/api/

  # Also, a good way to debug is to use selenium and get a browser
  # head to see whats going on
  # NOTE, you'll need the chrome webdriver from here:
  # http://code.google.com/p/chromedriver/downloads/list
  Capybara.register_driver :selenium_chrome do |app|
    Capybara::Selenium::Driver.new(app, :browser => :chrome)
  end
  Capybara::Screenshot.autosave_on_failure = false
  Capybara::Screenshot.register_filename_prefix_formatter(:rspec) do |example|
    "screenshot"
  end
  Capybara::Screenshot.webkit_options = { width: 1586, height: 768 }

  #Capybara.javascript_driver = :webkit_debug
  # Capybara.javascript_driver = :selenium_chrome
  Capybara.javascript_driver = :webkit
  Capybara.default_max_wait_time = 2
  # Capybara.automatic_reload = false

  Recognize::Application.config.skip_init_db = false

  #
  # Capybara.app_host = "http://0.0.0.0:3000"
  # Capybara.run_server = true
  # Capybara.server_port = 9000

  Capybara::Webkit.configure do |config|
    config.block_unknown_urls
    config.allow_url("https://js.stripe.com/v1/")
    config.allow_url("https://js.stripe.com/v2/")
    config.allow_url("js.stripe.com")
    config.allow_url("https://api.stripe.com/v1/tokens")
    config.allow_url("https://ajax.aspnetcdn.com/ajax/jquery.validate/1.8.1/jquery.validate.min.js")
    config.allow_url("http://cdnjs.cloudflare.com/ajax/libs/select2/4.0.0/css/select2.min.css")
    config.allow_url("http://cdnjs.cloudflare.com/ajax/libs/select2/4.0.0/js/select2.min.js")
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation, { :except => tables_not_to_truncate } #if this line changes, make to update elsewhere in tests
    # DatabaseCleaner.strategy = :transaction #if this line changes, make to update elsewhere in tests
    # DatabaseCleaner.strategy = :deletion

    User.send(:_create_system_user!)
    FactoryGirl.create(:leader_badge) unless Badge.find_by_name("leader")
    FactoryGirl.create(:boss_badge) unless Badge.find_by_name("boss")
    FactoryGirl.create(:on_fire_badge) unless Badge.find_by_name("on_fire")

    # Force tests to not use an asset host, even if overridden by local.yml
    ::Rails.configuration.action_controller.asset_host = nil
    Recognize::Application.config.asset_host = nil
    CarrierWave::Uploader::Base.asset_host = nil

    # User.send(:_create_system_user!)#this seems redundant to the before(:each) call but its not, trust me
  end

  config.before(:each) do
    print "\nRunning test: #{self.example.metadata[:example_group][:file_path]}:#{self.example.metadata[:example_group][:line_number]}" if ENV['DEBUG']
    DatabaseCleaner.start
    # User.send(:_create_system_user!)
    # User.system_user.roles.reload
    # User.system_user.user_roles.reload
  end

  config.after(:each) do
    unless Recognize::Application.config.skip_init_db
      DatabaseCleaner.clean
      init_db!
    end
  end

  config.after(:suite) do
    # Can't use VCR. Ex.
    # Do a lookup on a plan and doesn't exist(vcr records cassette)
    # Then we create plan(vcr records cassete)
    # Then we do another lookup on the plan - it should be there, but vcr pulls the cassette from step 1 where its missing

    begin
      Stripe::Plan.all(created: {gt: Time.now.midnight.to_i}).data.each do |stripe_plan|
        if stripe_plan.id.match(/\[test\]/)
          plan = Stripe::Plan.retrieve(stripe_plan.id)
          plan.delete
        end
      end
    rescue Stripe::APIConnectionError
      Rails.logger.debug "Could not connect to Stripe. This is expected if internet is down."
    end
  end
end

include ApplicationHelper
include Authlogic::TestCase
include UserSessionHelper
include RspecHelper
include AsynchronousHelper
include CapybaraHelper
Capybara::Session.send(:include, Rails.application.routes.url_helpers)

# for some reason, rspec isn't pulling in controller based helpers, even though it should...
class ActionView::TestCase::TestController
  def sharepoint_viewer?
    false
  end

  helper_method :sharepoint_viewer?
end

if Delayed::Worker.delay_jobs
  puts ""
  puts " *** Configuration Error ***: Delayed::Worker.delay_jobs is set to true.  This will cause problems in the test suite.  Check config/local.yml"
  puts ""
  exit
end


# This code will be run each time you run your specs.
# hack to force assets to be rendered relatively
ActionController::Base.asset_host = nil


Capybara::Session.send(:include, CapybaraHelper::Session)

# # HACK to get capybara to use only a single connection
# class ActiveRecord::Base
#   mattr_accessor :shared_connection
#   @@shared_connection = nil

#   def self.connection
#     @@shared_connection || retrieve_connection
#   end
# end
# ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection

# HACK for capybara's intermittent freezing: https://github.com/jnicklas/capybara/issues/725
# require 'quality_extensions//enumerable/grep_plus_offset'
# module Capybara
#   module Node
#     Base.class_eval do
#       def synchronize(seconds=Capybara.default_wait_time)
#         retries = (seconds.to_f / 0.05).round

#         begin
#           begin
#             @synchronize_nesting ||= 0
#             @synchronize_nesting += 1
#             #puts %(@synchronize_nesting=#{(@synchronize_nesting).inspect}: )
#             #pp caller(0).grep_plus_offset(/in `synchronize'/, 1)
#             yield
#           ensure
#             @synchronize_nesting -= 1
#           end
#         rescue => e
#           Rails.logger.debug %(#{@synchronize_nesting} retries=#{(retries).inspect} e=#{(e).inspect})
#           # sleep 0.05
#           # puts %(#{@synchronize_nesting} retries=#{(retries).inspect} e=#{(e).inspect})
#           raise e unless driver.wait?
#           raise e unless driver.invalid_element_errors.include?(e.class) or e.is_a?(Capybara::ElementNotFound)
#           raise e if retries.zero? or @synchronize_nesting > 0
#           sleep(0.05)
#           reload if Capybara.automatic_reload
#           retries -= 1
#           retry
#         end
#       end
#     end
#   end
# end
