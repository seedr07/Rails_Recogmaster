class AddTotalPointsToTeam < ActiveRecord::Migration
  def change
    add_column :teams, :total_member_points, :integer, default: 0
    add_column :teams, :total_team_points, :integer, default: 0
  end
end
