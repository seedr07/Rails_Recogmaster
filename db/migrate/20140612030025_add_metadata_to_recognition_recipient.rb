class AddMetadataToRecognitionRecipient < ActiveRecord::Migration
  def change
    add_column :recognition_recipients, :metadata, :text, limit: 4294967295
  end
end
