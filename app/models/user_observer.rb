class UserObserver < ActiveRecord::Observer
  def after_create(user)

    #if the user was invited, send invitation email

    if user.invited?
      deliver_invitation_email!(user)

    elsif user.invited_from_recognition?
      #do nothing...we'll send a special email when the recognition is created
      
    #otherwise, send normal verification email
    elsif user.created_by == :oauth
      UserNotifier.delay(queue: 'priority').welcome_email(user)

    elsif !user.pending_invite?
      deliver_verification_email!(user) 
    end
    
    user.company.delay(queue: 'caching').refresh_cached_users!
  end

  def after_save(user)
    if user.avatar.default? and user.auth_with_yammer?
      user.delay.sync_yammer_avatar!  
    end
  end

  def after_destroy(user)
    user.company.refresh_cached_users!
  end

  def deliver_invitation_email!(user)
    user.reset_perishable_token!
    UserNotifier.delay(queue: 'priority').invitation_email(user)
  end


  def deliver_verification_email!(user)
    user.reset_perishable_token!
    UserNotifier.delay(queue: 'priority').verification_email(user)
  end
  
end
