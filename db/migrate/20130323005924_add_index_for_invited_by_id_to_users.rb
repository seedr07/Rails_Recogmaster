class AddIndexForInvitedByIdToUsers < ActiveRecord::Migration
  def change
    add_index :users, :invited_by_id
  end
end
