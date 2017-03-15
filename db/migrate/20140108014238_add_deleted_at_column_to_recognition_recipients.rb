class AddDeletedAtColumnToRecognitionRecipients < ActiveRecord::Migration
  def change
    add_column :recognition_recipients, :deleted_at, :datetime
  end
end
