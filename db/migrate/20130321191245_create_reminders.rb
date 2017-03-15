class CreateReminders < ActiveRecord::Migration
  def change
    create_table :reminders do |t|
      t.integer :user_id
      t.datetime :no_invites_and_no_recognitions_reminder_sent_at
      t.datetime :invited_but_no_recognitions_reminder_sent_at
      t.datetime :inactive_user_reminder_sent_at
      t.timestamps
    end
    add_index :reminders, :user_id
  end
end
