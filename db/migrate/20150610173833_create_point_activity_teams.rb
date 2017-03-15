class CreatePointActivityTeams < ActiveRecord::Migration
  def change
    create_table :point_activity_teams do |t|
      t.integer :point_activity_id
      t.integer :team_id
      t.timestamps
    end

    add_index :point_activity_teams, :team_id
    add_index :point_activity_teams, :point_activity_id
    add_index :point_activity_teams, [:team_id, :point_activity_id], name: :pat_compound
  end
end
