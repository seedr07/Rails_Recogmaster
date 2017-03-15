class AddCreatedByFieldToTeams < ActiveRecord::Migration
  def up
    add_column :teams, :created_by_id, :integer
    Team.reset_column_information
    Team.includes(:team_managers).each do |t|
      if t.team_managers.present?
        t.created_by_id = t.team_managers.first.id
        t.save
      end
    end
  end

  def down
    remove_column :teams, :created_by_id
  end
end
