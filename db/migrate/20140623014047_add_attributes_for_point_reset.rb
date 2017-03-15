class AddAttributesForPointReset < ActiveRecord::Migration
  def change
  	add_column :companies, :reset_interval, :integer, default: Interval::MONTHLY
  	add_column :users, :interval_points, :integer, default: 0
  	add_column :teams, :interval_team_points, :integer, default: 0
  	add_column :teams, :interval_member_points, :integer, default: 0
  end
end
