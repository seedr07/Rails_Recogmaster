class AddRedeemableFlagToPointActivity < ActiveRecord::Migration
  def change
    add_column :point_activities, :is_redeemable, :boolean
  end
end
