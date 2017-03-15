class Team < ActiveRecord::Base
  include Points::Calculator

  acts_as_paranoid

  attr_accessible :name, :company
  has_many :user_teams, :dependent => :destroy
  has_many :users, :through => :user_teams
  has_many :team_managers, dependent: :destroy, inverse_of: :team
  belongs_to :company
  belongs_to :creator, class_name: "User", foreign_key: "created_by_id"
  
  has_many :point_activity_teams, inverse_of: :team, dependent: :destroy
  has_many :nominations, as: :recipient, dependent: :destroy
  
  DEFAULT_SET = ["Marketing", "Human Resources", "Engineering", "Sales", "IT"]
  validates :name, :company_id, :network, presence: true
  validates :name, uniqueness: {scope: [:company_id, :deleted_at]}
  
  before_validation :ensure_network
  before_validation :capitalize_first_letter

  def self.default_set
    DEFAULT_SET
  end

  def as_json(options={})
    options[:only] ||= [:id, :name]
    options[:methods] ||= [:total_points, :label, :type]
    super(options)
  end

  def label
    self.name
  end

  def type
    self.class.to_s
  end

  def full_name
    self.label
  end

  def recognitions
    @team_recognitions ||= received_recognitions
  end
  
  def received_recognitions
    return (member_recognitions + team_recognitions).sort{|a,b| b.created_at <=> a.created_at}
  end

  def member_recognitions
    member_ids = self.user_teams.map(&:user_id)
    Recognition.non_system
      .joins(:recognition_recipients)
      .where(recognition_recipients: {user_id: member_ids, team_id: nil, company_id: nil})
      .uniq
  end

  def team_recognitions
    Recognition.non_system
      .joins(:recognition_recipients)
      .where(recognition_recipients: {team_id: self.id, company_id: nil})
      .uniq
  end
  
  def badges_with_count(opts={})
    set = opts[:restrict_to_interval] ?
      Recognition.restricted_to_interval(self.company.reset_interval).where(id: recognitions.map(&:id)) :
      Recognition.where(id: recognitions.map(&:id))

    counts = set.group(:badge_id).count(:badge_id)
    badges = Badge.where(id: counts.keys)
    badge_counts = badges.collect do |badge|
      [badge, counts[badge.id]]
    end
    badge_counts.sort{ |a,b| b[1] <=> a[1] }
  end

  def skills
    # FIXME: stub
    [
      ["Excel", 100],
      ["Powerpoint", 70],
      ["Copywriting", 50],
      ["Speaking", 30],
      ["Email Marketing", 10],
    ].map{|item| Hashie::Mash.new({name: item[0], count: item[1]})}
  end

  def managers
    team_managers.present? ?
      team_managers.map(&:manager) :
      company.company_admins
  end

  def add_managers(users)
    users = Array(users)
    users.map do |user|
      team_managers.create(manager: user)
    end
  end

  def remove_managers(users)
    users = Array(users)
    users.map do |user|
      team_managers.where(manager: user).destroy_all.first
    end
  end

  def add_member(user)
    user_teams.create(user: user)
  end

  def remove_member(user)
    users.destroy(user)
  end

  def res_score
    ResCalculator.new(self).res_score
  end

  protected
  def ensure_network
    self.network = self.company.domain
  end
  
  def capitalize_first_letter
    if self.name.present?
      n = self.name
      self.name = (n.slice(0) || n.chars('')).upcase + (n.slice(1..-1) || n.chars(''))
    end
  end
end
