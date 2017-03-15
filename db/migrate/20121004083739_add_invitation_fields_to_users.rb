class AddInvitationFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :invited_by_id, :integer
    add_column :users, :invited_at, :datetime
  end
end
