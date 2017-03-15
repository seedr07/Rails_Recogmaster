class DropAccountsAvailableFromCompanies < ActiveRecord::Migration
  def up
    remove_column :companies, :accounts_available
  end

  def down
    add_column :companies, :accounts_available, :integer
  end
end
