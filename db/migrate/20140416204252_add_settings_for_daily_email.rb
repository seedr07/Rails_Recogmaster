class AddSettingsForDailyEmail < ActiveRecord::Migration
  def change
    add_column :companies, :allow_daily_emails, :boolean, default: false
    add_column :email_settings, :daily_updates, :boolean, default: false
  end

end
