Slack.configure do |config|
  if Recognize::Application.config.credentials["slack"]
    config.token = Recognize::Application.config.credentials["slack"]["incoming_token"] 
  end
end