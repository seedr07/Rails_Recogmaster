class CreateSupportEmails < ActiveRecord::Migration
  def change
    create_table :support_emails do |t|
      t.string :name
      t.string :email
      t.text :message

      t.timestamps
    end
  end
end
