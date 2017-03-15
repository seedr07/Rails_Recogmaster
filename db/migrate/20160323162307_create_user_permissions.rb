class CreateUserPermissions < ActiveRecord::Migration
  def change
    create_table :user_permissions do |t|
      t.integer :user_id, null: false
      t.integer :permission_id, null: false
      t.timestamps null: false
    end
  end
end
