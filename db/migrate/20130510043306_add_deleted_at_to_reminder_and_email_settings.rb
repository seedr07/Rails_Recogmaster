class AddDeletedAtToReminderAndEmailSettings < ActiveRecord::Migration
  def change
    add_column :reminders, :deleted_at, :datetime
    add_column :email_settings, :deleted_at, :datetime
  end
end
