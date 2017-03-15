class AddMoreEmailSettings < ActiveRecord::Migration
  def change
    add_column :email_settings, :monthly_updates, :boolean, default: true
    add_column :email_settings, :activity_reminders, :boolean, default: true
  end
end
