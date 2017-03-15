class AddReminderEmails < ActiveRecord::Migration
  def change
    rename_column :reminders, :has_not_verified_warning_sent_at, :has_not_verified_first_warning_sent_at 
    add_column :reminders, :has_not_verified_second_warning_sent_at, :datetime
    add_column :reminders, :has_not_verified_third_warning_sent_at, :datetime
  end

end
