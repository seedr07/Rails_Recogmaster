class SettingForShowingTeams < ActiveRecord::Migration
  def change
    add_column :companies, :allow_teams, :boolean, default: true
  end
end
