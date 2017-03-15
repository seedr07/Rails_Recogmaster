class FixUserCompanyRoles < ActiveRecord::Migration
  def change
    rename_column(:user_company_roles, :company_id, :company_role_id)
  end
end
