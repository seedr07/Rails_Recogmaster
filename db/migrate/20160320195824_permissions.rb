class Permissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.string :target_class, null: false
      t.string :target_action, null: false
      t.integer :target_id
      t.timestamps null: false
    end
  end
end
