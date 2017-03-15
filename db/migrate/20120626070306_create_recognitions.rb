class CreateRecognitions < ActiveRecord::Migration
  def change
    create_table :recognitions do |t|
      t.integer :badge_id
      t.integer :sender_id
      t.integer :recipient_id
      t.string :recipient_type
      t.text :message
      t.timestamps
    end
  end
end
