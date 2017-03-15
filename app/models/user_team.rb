class UserTeam < ActiveRecord::Base
  
  acts_as_paranoid

  belongs_to :user
  belongs_to :team

  validates_uniqueness_of :user_id, :scope => [:team_id, :deleted_at]
end
