class MigrateRecognitionRecipients
  def self.run!
    log "Migrating users"
    RecognitionRecipient.where(recipient_type: "User")
      .update_all("recognition_recipients.user_id = recognition_recipients.recipient_id")

    log "Migrating teams"
    count = RecognitionRecipient.where(recipient_type: "Team").count
    RecognitionRecipient.where(recipient_type: "Team").each_with_index do |rr, i|
      log "Migrating team(#{i}/#{count}): #{rr.recognition_id}:#{rr.recipient_id}"
      migrate_team_recipient(rr)
    end

    log "Updating user counter caches"
    count = User.unscoped.count
    User.unscoped.pluck(:id).each_with_index do |id, i|
      log "Updating user counter cache(#{i}/#{count}): #{id}"
      User.unscoped.reset_counters(id, :recognition_recipients)
    end

    log "Updating company counter caches"
    count = Company.unscoped.count
    Company.unscoped.each_with_index do |c, index|
      log "Updating company counter cache #{index}/#{count}"
      c.refresh_all_counter_caches!
    end

  end

  def self.migrate_team_recipient(recognition_recipient)
    attributes = recognition_recipient.attributes.clone
    attributes.delete("id")
    attributes.delete("metadata")
    attributes.delete("recipient_type")

    attributes[:team_id] = recognition_recipient.recipient_id

    member_ids = recognition_recipient.metadata[:team_member_id_snapshot]

    member_ids.each do |member_id|
      # log " -- Creating recognition recipient for: #{member_id} "
      attributes[:user_id] = member_id
      User.unscoped do 
        RecognitionRecipient.create!(attributes)
      end
    end

  end

  def self.migrate_user_recipient(recognition_recipient)
    recognition_recipient.update_column(:user_id, rec)
  end

  def self.log(msg)
    Rails.logger.info "[MIGRATION] "+msg
  end

end