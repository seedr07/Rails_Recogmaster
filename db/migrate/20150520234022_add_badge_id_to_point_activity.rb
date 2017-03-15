class AddBadgeIdToPointActivity < ActiveRecord::Migration
  def change
    add_column :point_activities, :badge_id, :integer
    add_index :point_activities, :badge_id
  end
end
