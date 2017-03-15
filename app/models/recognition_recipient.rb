class RecognitionRecipient < ActiveRecord::Base
  acts_as_paranoid
  serialize :metadata

  belongs_to :recognition
  belongs_to :user, counter_cache: :received_recognitions_count
  # belongs_to :recipient, polymorphic: true, counter_cache: :received_recognitions_count
  # validates :recipient_type, presence: true

  # it would be nice to have this validation on all the time , but can't due to save order when 
  # saving a recognition that is sent to a new user.  This model gets saved before the user model 
  # gets saved so in that case we don't have recipient company id and network
  validates :recipient_company_id, :recipient_network, presence: true, if: -> { user.persisted? }

  before_validation :set_company
  # before_create :snapshot_team_member_ids

  # scope :user, ->{where(recipient_type: "User")}
  # scope :team, ->{where(recipient_type: "Team")}

  # def user?
  #   recipient_type == "User"
  # end

  # def team?
  #   recipient_type == "Team"
  # end

  private

  def set_company
    self.recipient_company_id = user.company_id
    self.recipient_network = user.network
  end

end