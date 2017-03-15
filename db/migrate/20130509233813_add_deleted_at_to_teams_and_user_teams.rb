class AddDeletedAtToTeamsAndUserTeams < ActiveRecord::Migration
  def change
    add_column :teams, :deleted_at, :datetime
    add_column :user_teams, :deleted_at, :datetime
  end
end
