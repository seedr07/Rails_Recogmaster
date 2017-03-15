class PointActivity < ActiveRecord::Base
  ALLOWED_TYPES = [
    "recognition_recipient", 
    "recognition_sender", 
    "recognition_approval_giver", 
    "recognition_approval_receiver",
    "redemption"
  ]

  belongs_to :user
  belongs_to :recognition
  belongs_to :company

  has_many :point_activity_teams, inverse_of: :point_activity, dependent: :destroy

  before_validation :set_company

  validates :amount, :activity_type, :company_id, :network, :user_id, presence: true
  validates :is_redeemable, :inclusion => {:in => [true, false]}
  validates :activity_object_type, :activity_object_id, presence: true
  validates :activity_type, inclusion: {in: ALLOWED_TYPES}

  after_commit :snapshot_user_teams, on: :create

  scope :redeemable, ->{ where(is_redeemable: true)}
  scope :everything_but_redemptions, ->{ where.not(activity_type: 'redemption')}
  scope :redemptions, ->{ where(activity_type: 'redemption')}

  def self.for_activity(obj, user)
    where(user_id: user.id).
    where(activity_object_type: obj.class.to_s, activity_object_id: obj.id)

  end

  def activity_object=(object)
    self.activity_object_type = object.class.to_s
    self.activity_object_id = object.id
  end

  private
  def set_company
    self.company_id = user.company_id
    self.network = user.network
  end

  def snapshot_user_teams
    # transaction for faster inserts if many teams
    ActiveRecord::Base.transaction do
      user.user_teams.each do |user_team| 
        PointActivityTeam.create!(point_activity_id: self.id, team_id: user_team.team_id) 
      end
    end
  end


  class Type
    def self.recognition_recipient
      "recognition_recipient"
    end
  end
end
