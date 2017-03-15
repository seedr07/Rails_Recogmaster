class TeamManager < ActiveRecord::Base
  belongs_to :team, inverse_of: :team_managers
  belongs_to :manager, class_name: "User"

  validates :team, :manager_id, presence: true
  validate :manager_is_in_company
  validates :manager_id, uniqueness: {scope: :team_id, message: "is already a manager of this team"}

  private
  def manager_is_in_company
    unless manager.company_id == team.company_id
      errors[:manager_id] = "must be in your company"
    end
  end
end