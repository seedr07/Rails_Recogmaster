class AddNewCommentEmailNotificationSetting < ActiveRecord::Migration
  def up
    add_column :email_settings, :new_comment, :boolean, default: true
  end

  def down
  end
end
