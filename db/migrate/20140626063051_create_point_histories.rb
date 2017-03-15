class CreatePointHistories < ActiveRecord::Migration
  def change
    create_table :point_histories do |t|
      t.integer :owner_id
      t.string :owner_type
      t.integer :points
      t.integer :team_points
      t.integer :member_points
      t.date :date

      t.timestamps
    end

    add_index :point_histories, [:owner_id, :owner_type]
  end
end
