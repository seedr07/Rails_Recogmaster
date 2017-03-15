class MigrateDataToMultipleRecipientModel < ActiveRecord::Migration
  def up
    Recognition.where(nil).each do |r|
#      recipient = User.find(r.recipient_id)
#      r.recipients = [recipient]
#      r.save
      RecognitionRecipient.create!(recognition: r, recipient_type: "User", recipient_id: r.recipient_id)
    end
  end

  def down
  end
end
