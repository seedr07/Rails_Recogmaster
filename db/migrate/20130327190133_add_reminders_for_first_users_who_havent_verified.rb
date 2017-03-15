class AddRemindersForFirstUsersWhoHaventVerified < ActiveRecord::Migration
  def change
    add_column :reminders, :has_not_verified_warning_sent_at, :datetime
    add_column :reminders, :has_not_verified_and_is_now_disabled_sent_at, :datetime
  end
end
