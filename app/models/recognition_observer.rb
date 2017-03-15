class RecognitionObserver < ActiveRecord::Observer
  def after_create(recognition)
    recognition.recognition_recipients.each do |rr|
      if rr.team_id.present?
        after_create_for_team(recognition, Team.find(rr.team_id))
      elsif rr.company_id.present?
        after_create_for_company(recognition, Company.find(rr.company_id))
      end

      after_create_for_user(recognition, rr.user)

      # this is a sanity to check to make sure we set these
      rr.send(:set_recipient_company).save! if rr.recipient_company_id.blank? || rr.recipient_network.blank?

    end
    recognition.sender.delay(queue: 'caching').refresh_cached_user_graph!

  end

  def after_destroy(recognition)
    recognition.sender.delay(queue: 'caching').refresh_cached_user_graph!
    recognition.recognition_recipients.each do |r|
      send("after_destroy_for_#{r.class.to_s.downcase}", recognition, r)
    end

  end    

  protected
  def after_create_for_user(recognition, user)
    if !user.invited_from_recognition?
      RecognitionNotifier.delay(queue: 'priority').new_recognition_for_user(recognition, user) unless recognition.badge.ambassador?
    else
      if recognition.cross_company?(user)
        RecognitionNotifier.delay(queue: 'priority').invite_from_crosscompany_recognition_for_user(recognition, user)
      else
        RecognitionNotifier.delay(queue: 'priority').invite_from_recognition_for_user(recognition, user)
      end
    end

    user.refresh_cached_user_graph!
    
  end

  def after_destroy_for_user(recognition, user)
    user.refresh_cached_user_graph!
  end

  def after_create_for_company(recognition, company)
    RecognitionNotifier.new_recognition_for_company(recognition, company)
  end

  def after_destroy_for_company(recognition, company)
  end

  def after_create_for_team(recognition, team)
    team.users.each do |user|      
      RecognitionNotifier.delay(queue: 'priority').new_recognition_for_team(recognition, team, user) unless recognition.user_recipients.include?(user)
    end
  end

  def after_destroy_for_team(recognition, team)
    raise "not implemented!"
  end
end
