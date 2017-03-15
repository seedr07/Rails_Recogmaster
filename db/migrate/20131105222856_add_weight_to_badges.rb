class AddWeightToBadges < ActiveRecord::Migration
  def change
    add_column :badges, :points, :integer
  end
end
