class AddNetworkToTeams < ActiveRecord::Migration
  def up
    add_column :teams, :network, :string
    add_index :teams, :network
    Team.reset_column_information
    Company.reset_column_information
    Team.joins(:company).includes(:company).all.each do |t|
      t.update_attribute :network, t.company.domain
    end
  end
  
  def down
    remove_index :teams, :network
    remove_column :teams, :network
  end
end
