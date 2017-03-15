class UniqUserCompanyRole < ActiveRecord::Migration
  def change
    add_index :user_company_roles, [:user_id, :company_role_id], unique: true
  end
end
