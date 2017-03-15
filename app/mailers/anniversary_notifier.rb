class AnniversaryNotifier < ActionMailer::Base
  include MailHelper
  default from: "Recognize <donotreply@recognizeapp.com>"
  layout "mailer"
  helper :mail
  helper :application
  
  def notify_anniversaries(user, anniversary_array)
    @user = user
    @anniversary_array = anniversary_array
    mail(to: @user.email, subject: "Today's Anniversaries", track_opens: true)
  end

end