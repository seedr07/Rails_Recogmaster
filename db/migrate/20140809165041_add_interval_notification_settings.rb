class AddIntervalNotificationSettings < ActiveRecord::Migration
  def change
    add_column :email_settings, :interval_winner_notifications, :boolean, default: true
    add_column :companies, :allow_interval_winner_notifications, :boolean, default: true
  end
end
