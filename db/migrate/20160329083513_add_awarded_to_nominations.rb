class AddAwardedToNominations < ActiveRecord::Migration
  def change
    add_column :nominations, :awarded, :boolean
  end
end
