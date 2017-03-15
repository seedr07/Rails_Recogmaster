class Recognizebot
  attr_reader :opts, :client

  def self.say(opts)
    new(opts).say_it
  end

  def initialize(opts)
    @opts = opts
    @client = Slack::Web::Client.new
  end

  def say_it
    options = {}
    options[:channel] = "#test"
    options[:username] = "recognizebot"
    options[:icon_url] =  "https://recognizeapp.com/assets/chrome/logo_48x48.png"
    options.merge!(opts)
    if Recognize::Application.config.credentials["slack"]
      client.chat_postMessage(options)  
    else
      Rails.logger.warn "Slack has not been configured! Please add tokens to credentials.yml"
    end
  end
end