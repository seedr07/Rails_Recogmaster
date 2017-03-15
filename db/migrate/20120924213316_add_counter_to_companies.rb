class AddCounterToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :accounts_available, :integer, default: 1
  end
end
