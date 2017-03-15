class AddDescriptionToRewards < ActiveRecord::Migration
  def change
    add_column :rewards, :description, :string
  end
end
