class UniqCompanyRole < ActiveRecord::Migration
  def change
    add_index :company_roles, [:name, :company_id], unique: true
  end
end
