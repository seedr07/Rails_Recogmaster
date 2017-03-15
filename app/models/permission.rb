class Permission < ActiveRecord::Base
  validate :target_class, presence: true
  validate :target_action, presence: true

  has_many :company_role_permissions, dependent: :destroy
  has_many :company_roles, through: :company_role_permissions

  # TODO
  # when target_id is selected do we want to validate it against db
  # or just assume that wrapper classes never insert bad ids?

  def self.find_or_create!(target_action:, target_class:, target_id:)
    self.find_by(
        target_action: target_action,
        target_class: target_class.to_s,
        target_id: target_id
    ) || self.create!(
        target_action: target_action,
        target_class: target_class.to_s,
        target_id: target_id
    )
  end
end
