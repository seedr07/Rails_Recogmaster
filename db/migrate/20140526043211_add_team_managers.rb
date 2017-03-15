class AddTeamManagers < ActiveRecord::Migration
  def change
    create_table :team_managers do |t|
      t.integer :manager_id
      t.integer :team_id
    end
    TeamManager.reset_column_information
    add_index :team_managers, :team_id
    add_index :team_managers, :manager_id
    add_index :team_managers, [:team_id, :manager_id]
  end
end
