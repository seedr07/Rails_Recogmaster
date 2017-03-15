class CompanyRolePermission < ActiveRecord::Base
  belongs_to :permission
  belongs_to :company_role
end
