class RecognitionNotifier < ActionMailer::Base
  include MailHelper
  default from: "Recognize <donotreply@recognizeapp.com>"
  layout "recognition_mailer"
  helper :mail
  helper :application

  def new_recognition_for_user(recognition, user)
    @recognition = recognition
    @badge = @recognition.badge
    @sender = @recognition.sender
    @recipient = user
    @user = @recipient
    if @recipient.accepts_email?(:new_recognition)
      mail(to: @recipient.email, subject: recognition_subject, track_opens: true)
    end
  end

  def new_recognition_for_team(recognition, team, user)
    @recognition = recognition
    @team = team
    @badge = @recognition.badge
    @sender = @recognition.sender
    @recipient = user
    @user = @recipient
    if @recipient.accepts_email?(:new_recognition)
      mail(to: @recipient.email, subject: "#{@team.name} is recognized by #{@sender.full_name}!", track_opens: true)
    end
  end

  # def new_recognition_for_company(recognition, company)
  #   raise "not implemented!"
  #   @recognition = recognition
  #   @badge = @recognition.badge
  #   @sender = @recognition.sender
  #   @recipient = company.company_admin || company.users.first

  #   raise "company has no users to send an email to " unless @recipient.present?
  #   @user = @recipient
  #   if @recipient.accepts_email?(:new_recognition)
  #     mail(to: @recipient.email, from: @sender.formatted_email, subject: recognition_subject) do |format|
  #       format.html {render layout: "recognition_mailer"} 
  #     end
  #   end
  # end

  def invite_from_recognition_for_user(recognition, user)
    @recognition = recognition
    @badge = @recognition.badge
    @sender = @recognition.sender
    @recipient = user
    @user = @recipient

    @recipient.reset_perishable_token! if @recipient.perishable_token.blank?
    @verification_url = verify_signup_url(@recipient.perishable_token)
    mail(to: @recipient.email, from: @sender.formatted_email, subject: recognition_subject, track_opens: true)
  end

  def invite_from_crosscompany_recognition_for_user(recognition, user)
    @recognition = recognition
    @badge = @recognition.badge
    @sender = @recognition.sender
    
    @recipient = user
    @user = @recipient
    @recipient.reset_perishable_token! if @recipient.perishable_token.blank?
    @verification_url = verify_signup_url(@recipient.perishable_token)
    
    mail(to: @recipient.email, from: @sender.formatted_email, subject: recognition_subject, track_opens: true)
  end

  private

  def recognition_subject
    subject = "#{@sender.full_name} recognized you!"
  end
end