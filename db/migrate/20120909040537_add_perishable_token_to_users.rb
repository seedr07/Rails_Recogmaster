class AddPerishableTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :perishable_token, :string, default: "", null: false
  end
end
