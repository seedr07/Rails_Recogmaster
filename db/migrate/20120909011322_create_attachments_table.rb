class CreateAttachmentsTable < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.string :file
      t.string :type
      t.integer :owner_id
      t.string :owner_type
      t.timestamps
    end
  end    
end
