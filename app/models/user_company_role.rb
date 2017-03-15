class UserCompanyRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :company_role

  validates :user_id, presence: true, uniqueness: { scope: [:company_role_id], message: "already has company role" }
  validate :company_role_id, presence: true
end
