class RedemptionNotifier < ActionMailer::Base
  include MailHelper
  default from: "Recognize <donotreply@recognizeapp.com>"
  layout "mailer"
  helper :mail
  helper :application
  
  def notify_of_redemption(user,redemption)
    @user = user
    @admin = redemption.reward.manager
    @reward = redemption.reward
    mail(to: @user.email, subject: t("rewards.youve_redeemed"), track_opens: true)
  end

  def notify_admin_of_redemption(user, redemption)
    @user = redemption.reward.manager
    @redeeming_user = user
    @reward = redemption.reward
    mail(to: @user.email, subject: t("rewards.user_has_redeemed", name: @redeeming_user.full_name), track_opens: true)
  end

end