class AddIndexToSlugsOnUsers < ActiveRecord::Migration
  def change
    add_index :users, :slug
    add_index :companies, :slug
  end
end
