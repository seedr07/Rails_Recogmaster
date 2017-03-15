class AddCounterCacheToCompany < ActiveRecord::Migration
  def up
    add_column :companies, :user_count, :integer, :default => 0
    add_column :companies, :recognition_count, :integer, :default => 0
    Company.reset_column_information
#    Company.with_deleted.all.each do |c|
#      Company.reset_counters c.id, :users, :recognitions
#    end
  end
  
  def down
    remove_column :companies, :user_count
  end
end
