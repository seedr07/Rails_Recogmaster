class AddDefaultValuesToNominations < ActiveRecord::Migration
  def up
    rename_column :nominations, :archive, :is_archived
    rename_column :nominations, :awarded, :is_awarded
    change_column :nominations, :is_archived, :boolean, default: false
    change_column :nominations, :is_awarded, :boolean, default: false
  end

  def down
    rename_column :nominations, :is_archived, :archive
    rename_column :nominations, :is_awarded, :awarded
  end
end
