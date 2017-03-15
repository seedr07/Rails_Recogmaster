class AddIndexToRewardsAndRedemptions < ActiveRecord::Migration
  def change
    add_index :rewards, :company_id
    add_index :rewards, :deleted_at
    add_index :redemptions, :deleted_at
    add_index :redemptions, :reward_id
    add_index :redemptions, [:user_id, :deleted_at]
  end
end
