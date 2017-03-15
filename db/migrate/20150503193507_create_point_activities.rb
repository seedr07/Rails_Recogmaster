class CreatePointActivities < ActiveRecord::Migration
  def change
    create_table :point_activities do |t|
      t.integer :amount
      t.string :activity_type
      t.integer :recognition_id
      t.integer :user_id
      t.integer :company_id
      t.string :network
      t.string :activity_object_type
      t.string :activity_object_id

      t.timestamps
    end

    add_index :point_activities, :recognition_id
    add_index :point_activities, :user_id
    add_index :point_activities, :company_id
    add_index :point_activities, :network
    add_index :point_activities, [:activity_object_type, :activity_object_id], name: "activity_object_index"
  end
end
