class AddYammerIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :yammer_id, :integer
  end
end
