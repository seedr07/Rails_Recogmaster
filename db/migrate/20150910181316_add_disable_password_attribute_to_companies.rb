class AddDisablePasswordAttributeToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :disable_passwords, :boolean, default: false
  end
end
