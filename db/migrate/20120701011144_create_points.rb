class CreatePoints < ActiveRecord::Migration
  def change
    create_table :points do |t|
      t.integer :giver_id
      t.integer :recognition_id

      t.timestamps
    end
  end
end
