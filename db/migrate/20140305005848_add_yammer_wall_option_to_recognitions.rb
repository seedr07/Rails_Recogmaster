class AddYammerWallOptionToRecognitions < ActiveRecord::Migration
  def change
    add_column :recognitions, :post_to_yammer_wall, :boolean, default: false
  end
end
