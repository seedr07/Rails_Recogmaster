MailJack.config do |config|
  config.mailers = [:email_blast, :reminder_notifier, :system_notifier, :user_notifier]
  config.href_filter = /#{Recognize::Application.config.host}/
  config.encode_to = :source
  config.trackable do |track|
    track.campaign = lambda{|mailer| mailer.action_name}
    track.campaign_group = lambda{|mailer| mailer.class.name}
  end
end
