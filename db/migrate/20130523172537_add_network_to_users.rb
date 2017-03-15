class AddNetworkToUsers < ActiveRecord::Migration
  def up
    add_column :users, :network, :string
    add_index :users, :network
    User.reset_column_information
    User.includes(:company).all.each do |u|
      #u.update_attribute :network, u.company.domain
      User.where(id: u.id).update_all(network: u.company.domain)
    end
  end
  
  def down
    remove_index :users, :network
    remove_column :users, :network
  end
end
