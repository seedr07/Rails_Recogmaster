class ChangeContactsColumnNameOnUsers < ActiveRecord::Migration
  def change
    rename_column :users, :contacts, :contacts_raw
  end

end
