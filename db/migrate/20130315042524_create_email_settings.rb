class CreateEmailSettings < ActiveRecord::Migration
  def change
    create_table :email_settings do |t|
      t.integer :user_id
      t.boolean :global_unsubscribe, default: false
      t.boolean :new_recognition, default: true
      t.boolean :weekly_updates, default: true
      t.timestamps
    end
  end
end
