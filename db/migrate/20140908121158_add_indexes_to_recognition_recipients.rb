class AddIndexesToRecognitionRecipients < ActiveRecord::Migration
  def change
    add_index :recognition_recipients, :recipient_company_id
    add_index :recognition_recipients, :recipient_network
  end
end
