class AddFlagForUsersToRemoveWelcomeScreen < ActiveRecord::Migration
  def change
    add_column :users, :has_read_welcome, :boolean, default: false
  end
end
