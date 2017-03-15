class MakeAllPointsDynamic < ActiveRecord::Migration
  def change
    add_column :companies, :point_values, :text
  end
end
