class AddContactsFieldToUsers < ActiveRecord::Migration
  def change
    add_column :users, :contacts, :text, limit: 4294967295
  end
end
