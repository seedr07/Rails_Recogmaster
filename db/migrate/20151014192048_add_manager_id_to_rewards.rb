class AddManagerIdToRewards < ActiveRecord::Migration
  def change
    add_column :rewards, :manager_id, :integer
  end
end
