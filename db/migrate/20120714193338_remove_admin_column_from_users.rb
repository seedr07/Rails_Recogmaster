class RemoveAdminColumnFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :is_company_admin
  end

  def down
    add_column :users, :is_company_admin, :boolean, default: false
  end
end
