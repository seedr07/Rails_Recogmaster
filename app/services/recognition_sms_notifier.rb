class RecognitionSmsNotifier
  include Rails.application.routes.url_helpers

  def on_recognition_created(recognition)
    recipients = recognition.user_recipients
    recipients.each do |r|
      ::SmsNotifier.send!(r, content(recognition, r))
    end
  rescue => e
    ExceptionNotifier.notify_exception(e, {data: {recognition: recognition.slug}})    
  end

  def sender(recognition)
    recognition.sender.full_name
  end

  def content(recognition, recipient)
    url_opts = {host: Recognize::Application.config.host}
    unless recipient.active?
      recipient.reset_perishable_token! if recipient.perishable_token.blank?
      url_opts[:invite] = recipient.perishable_token
    end

    "#{sender(recognition)} recognized you! #{recognition_url(recognition, url_opts)}"
  end
end