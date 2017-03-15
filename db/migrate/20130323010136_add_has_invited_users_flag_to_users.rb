class AddHasInvitedUsersFlagToUsers < ActiveRecord::Migration
  def up
    add_column :users, :invited_users_count, :integer, default: 0
    User.reset_column_information
#    User.with_deleted.all.each do |u|
#      User.reset_counters(u.id, :invited_users)
#    end
  end
  
  def down
    remove_column :users, :invited_users_count
  end
end
