class CreateRecognitionsRecipientsJoinModel < ActiveRecord::Migration
  def change
    create_table :recognition_recipients do |t|
      t.integer :recognition_id
      t.integer :recipient_id
      t.string :recipient_type
    end
    add_index :recognition_recipients, :recognition_id
    add_index :recognition_recipients, [:recipient_id, :recipient_type], name: "by_recognition_recipient"

    RecognitionRecipient.reset_column_information
  end
end
