class PushEvent
  def self.trigger(channel, event, object)
    #only send in production mode, but you can also
    #change in local.yml if you need to test outside of production
    Pusher[channel].trigger(event, object) if Rails.configuration.send_push_notifications
  end
  
end