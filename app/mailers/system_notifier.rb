class SystemNotifier < ActionMailer::Base
  default from: "Recognize <donotreply@recognizeapp.com>"
  layout "mailer"
  helper :mail
  
  def reminder_simulation(csv_file)
    attachments["#{Recognize::Application.config.host.to_s.downcase.gsub('.','-')}_reminder_simulation_#{Time.now.to_formatted_s(:db)}.csv"] = csv_file
    mail(to:"peter@recognizeapp.com", subject: "#{Recognize::Application.config.host} Tomorrow's email reminders - Here's what will run")
  end
  
  def contact_email(support_email)
    @support_email = support_email
    mail(
      from: "#{@support_email.email} <donotreply@recognizeapp.com>", 
      to: "support@recognizeapp.com", 
      subject: "Recognize #{@support_email.type} Request [#{Time.now.strftime('%Y%m%d%H%I')}]", 
      :"reply-to" => @support_email.email
      )
  end
  
  def signup_request(signup_request)
    @signup_request = signup_request
    mail(to: "support@recognizeapp.com", subject: "A new request to signup has been submitted!")
  end

  def new_subscription(subscription)
    @subscription = subscription
    mail(to: "support@recognizeapp.com", subject: "A new subscription has been purchased!")
  end

end