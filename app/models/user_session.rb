class UserSession < Authlogic::Session::Base
  include Rails.application.routes.url_helpers  

  attr_accessor :network
    
  validate :check_if_verified
  after_save :set_first_login_at
  
  disable_magic_states true
  
  def self.login_as!(user)
    user.reset_persistence_token!
    UserSession.create!(user)    
  end
  
  private

  def set_first_login_at
    attempted_record.update_attribute(:first_login_at, Time.now) unless attempted_record.first_login_at.present?
  end
  
  #taken from http://www.nathancolgate.com/post/184694426/adding-email-and-user-verification-to-authlogic
  def check_if_verified
    if attempted_record
      if !attempted_record.verified? and !attempted_record.active?
        link = "<a class='button button-small' href='#{resend_verification_email_path(email: attempted_record.email)}'>Resend Verification Email</a>".html_safe
        errors.add(:base, "You have not yet verified your email.  You may resend a verification link by clicking: #{link}".html_safe) 
      end
    end
  end
end