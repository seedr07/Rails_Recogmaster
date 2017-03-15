class CreateChat < ActiveRecord::Migration

  def change
    create_table :chat_messages do |t|
      t.belongs_to :chat_thread, index: true
      t.text :body
      t.integer :author_id
      t.timestamps null: false
    end

    create_table :chat_threads do |t|
      t.timestamps null: false
      t.string :email
      t.text :first_message
      t.integer :user_id
    end
  end
end
