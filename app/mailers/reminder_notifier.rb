class ReminderNotifier < ActionMailer::Base
  include MailHelper
  default from: "Recognize Team <team@recognizeapp.com>"
  layout "reminder_mailer"
  helper :mail
  
  def no_invites_and_no_recognitions_reminder(user)
    @user = user
    mail(to: user.email, subject: "Recognize a coworker for their good work")        
  end
  
  def invited_but_no_recognitions_reminder(user)
    @user = user
    mail(to: user.email, subject: "Is there a coworker who deserves recognition?")        
  end
  
  def inactive_user_reminder(user)
    @user = user
    mail(to: user.email, subject: "Appreciate a coworker today")        
  end

  def has_not_verified_first_warning(user);has_not_verified_warning(user, :first);end
  def has_not_verified_second_warning(user);has_not_verified_warning(user, :second);end
  def has_not_verified_third_warning(user);has_not_verified_warning(user, :third);end

  def has_not_verified_warning(user, warning_ordinal)
    @user = user
    @warning_ordinal
    @verification_url = verify_signup_url(user.perishable_token)    
    mail(to: user.email, subject: "Please verify your email with Recognize", template_name: "has_not_verified_warning")            
  end
  
  def has_not_verified_and_is_now_disabled(user)
    @user = user
    @verification_url = verify_signup_url(user.perishable_token)    
    mail(to: user.email, subject: "Your Recognize account is disabled")            
  end
  
  def company_disabled(user)
    @user = user
    mail(to: user.email, subject: "The account for your company is disabled")            
  end
end