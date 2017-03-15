class CreateInboundEmails < ActiveRecord::Migration
  def change
    create_table :inbound_emails do |t|
      t.string :sender_email
      t.string :status
      t.text :data
      t.timestamps
    end
    add_index :inbound_emails, :sender_email

    add_column :users, :from_inbound_email_id, :integer
    add_column :recognitions, :from_inbound_email_id, :integer
  end
end
