class AddCompanySettingForYammerManagerNotification < ActiveRecord::Migration
  def change
    add_column :companies, :allow_yammer_manager_recognition_notification, :boolean, default: false
  end
end
