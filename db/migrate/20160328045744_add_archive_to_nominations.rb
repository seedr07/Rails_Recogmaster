class AddArchiveToNominations < ActiveRecord::Migration
  def change
    add_column :nominations, :archive, :boolean
  end
end
