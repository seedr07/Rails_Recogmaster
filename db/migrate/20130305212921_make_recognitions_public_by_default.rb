class MakeRecognitionsPublicByDefault < ActiveRecord::Migration
  def up
    change_column :recognitions, :is_public, :boolean, default: true
  end

  def down
  end
end
