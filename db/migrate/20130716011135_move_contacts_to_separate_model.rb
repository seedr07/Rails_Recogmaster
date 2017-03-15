class MoveContactsToSeparateModel < ActiveRecord::Migration
  def up
    create_table :contact_lists do |t|
      t.integer :user_id
      t.text :contacts_raw, limit: 4294967295
    end
#    User.where(nil).each do |u|
#      u.contact_list = ContactList.new(user: u, contacts_raw: u.contacts_raw)
#      u.save
#    end
  end
  def down
    drop_table :contact_lists
  end
end
