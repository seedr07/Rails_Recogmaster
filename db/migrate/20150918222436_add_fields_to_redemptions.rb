class AddFieldsToRedemptions < ActiveRecord::Migration
  def change
    add_column :redemptions, :points_at_redemption_time, :integer
    add_column :rewards, :enabled, :boolean, default: true
  end
end
