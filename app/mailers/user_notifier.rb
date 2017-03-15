class UserNotifier < ActionMailer::Base
  include MailHelper
  default from: "Recognize <donotreply@recognizeapp.com>"
  layout "mailer"
  # layout false, only: "from_template"

  helper :mail
  helper :application
  
  def welcome_email(user)
    @user = user
    mail(to: user.email, subject: "Your account is ready", track_opens: true)    
  end

  def password_reset_instructions(user)  
    @user = user
    @edit_password_reset_url = edit_password_reset_url(user.perishable_token)
    mail(to: user.email, subject: "Password reset instructions for Recognize", track_opens: true)    
  end
  
  def verification_email(user)
    @user = user
    @verification_url = verify_signup_url(user.perishable_token)
    subject = @user.from_inbound_email_id.present? ? 
      "Please verify your email to send your recognition" : 
      "Welcome to Recognize! Please verify your email."
    mail(to: user.email, subject: subject, track_opens: true)
  end   
  
  def invitation_email(user)
    @user = user
    @verification_url = verify_signup_url(user.perishable_token)
    @inviter = user.invited_by
    @inviter_company = @inviter.company
    Rails.logger.debug "Inviting #{@user.email} from #{@inviter.full_name}(#{@inviter.email})"
    mail(to: user.email, from: user.invited_by.formatted_email, subject: "#{@inviter.full_name} invites you to Recognize!", track_opens: true)
  end
    
  def new_comment(recipient, comment)
    @recipient, @comment = recipient, comment
    @user = @recipient
    if @recipient.accepts_email?(:new_comment)
      mail(to: @recipient.email, from: comment.commenter.formatted_email, subject: "Commented on recognition, \"#{comment.content}\"", track_opens: true)
    end
  end

  def from_template(sender,recipient, subject, body)
    @user = recipient
    @sender = sender
    @body = body
    mail(to: @user.email, from: sender.email, subject: subject) do |format|
      format.html { render layout: nil }
    end
  end

end