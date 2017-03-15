#RAILS_ENV=production bin/rails r 'MigratePointValues.run!'
class MigratePointValues
  def self.run!(companies=nil)
    companies = Array(companies) if companies.present?

    clean_up_old_team_recognitions
    migrate_recognitions(companies)
    migrate_recognition_approvals(companies)
    update_user_point_values(companies)

  end

  def self.clean_up_old_team_recognitions
    log "Cleaning up old Team recognition recipients"
    RecognitionRecipient.where(recipient_type: "Team").update_all(deleted_at: Time.now)    
  end

  def self.migrate_recognitions(companies=nil)
    log "Migrating Recognitions"
    recognition_set = companies.present? ? companies.map(&:recognitions).flatten : Recognition.all

    count = recognition_set.count
    recognition_set.each_with_index do |r, i|
    # Recognition.where(sender_company_id: 1).each_with_index do |r, i|
      log " -- Migrating Recognition(#{i}/#{count}): #{r.id}"
      Timecop.freeze(r.created_at)
      begin
        PointActivity::Recorder.record!(r)
      rescue ActiveRecord::RecordNotFound => e
        log "caught ActiveRecord::RecordNotFound on recognition(#{r.id}): #{e.message}"
      end
    end
  end

  def self.migrate_recognition_approvals(companies=nil)
    recognition_approval_set = companies.present? ? companies.map{|c| c.recognitions.map(&:approvals)}.flatten : RecognitionApproval.all
    count = recognition_approval_set.count
    recognition_approval_set.each_with_index do |ra, i|
      log " -- Migrating RecognitionApproval(#{i}/#{count}): #{ra.id}"
      Timecop.freeze(ra.created_at)
      begin
        PointActivity::Recorder.record!(ra)
      rescue ActiveRecord::RecordNotFound => e
        log "caught ActiveRecord::RecordNotFound on recognition approval(#{ra.id}): #{e.message}"
      end
    end
  end

  def self.update_user_point_values(companies=nil)
    log " -- Updating User points"
    user_set = companies.present? ? companies.map(&:users).flatten : User.all
    count = user_set.size
    user_set.each_with_index do |u, i|
      log " -- Migrating User(#{i}/#{count}): #{u.id}"
      u.update_all_points!
    end
  end    

  def self.log(msg)
    msg = "[MIGRATION] "+msg
    Rails.logger.info msg
    puts msg
  end

  def self.reset!
    PointActivity.delete_all
    PointActivityTeam.unscoped.delete_all    
  end

end