class AddStatusToUsers < ActiveRecord::Migration
  def up
    add_column :users, :status, :string
    remove_column :users, :verified
    add_column :users, :verified_at, :datetime
  end
  
  def down
    remove_column :users, :verified_at
    add_column :users, :verified, :boolean
    remove_column :users, :status
  end
  
end
