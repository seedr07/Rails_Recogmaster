class CompanyRole < ActiveRecord::Base
  belongs_to :company
  has_many :user_roles
  has_many :users, through: :user_roles
  has_many :user_company_roles, dependent: :delete_all
  has_many :company_role_permissions, dependent: :delete_all
  has_many :direct_permissions, through: :company_role_permissions, source: "permission"

  validates :name, presence: true, uniqueness: { scope: [:company_id] }
  validates :company_id, presence: true

  def grant(permission)
    direct_permissions << permission
  end

  def revoke(permission)
    direct_permissions.delete(permission)
  end

  def permissions
    direct_permissions
  end
end
