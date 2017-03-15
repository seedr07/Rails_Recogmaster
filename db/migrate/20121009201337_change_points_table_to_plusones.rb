class ChangePointsTableToPlusones < ActiveRecord::Migration
  def up
    rename_table :points, :plus_ones
  end

  def down
    rename_table :plus_ones, :points
  end
end
