# Be sure to restart your server when you modify this file.

# Recognize::Application.config.session_store :cookie_store, key: '_recognize_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
opts =  {expire_after: 2.months, domain: :all}
opts[:key] = "Recognize-#{Rails.configuration.host}-#{`echo $USER`.strip}" unless Rails.configuration.host == "recognizeapp.com"
Recognize::Application.config.session_store :active_record_store, opts
