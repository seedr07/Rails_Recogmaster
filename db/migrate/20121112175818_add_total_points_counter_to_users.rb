class AddTotalPointsCounterToUsers < ActiveRecord::Migration
  def up
    add_column :users, :total_points, :integer, :default => 0
    User.reset_column_information
    User.with_deleted.all.each do |u|
      u.update_attribute :total_points, u.calculate_total_points
    end
  end
  
  def down
    remove_column :users, :total_points
  end
end
