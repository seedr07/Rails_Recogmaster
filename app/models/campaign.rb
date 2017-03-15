class Campaign < ActiveRecord::Base
  belongs_to :badge
  belongs_to :company, inverse_of: :campaign
  has_many :nominations, inverse_of: :campaign, dependent: :destroy

  before_validation :set_interval_from_badge

  validates :badge_id, :start_date, :end_date, :company_id, presence: true
  validates :interval_id, presence: true, if: ->{ badge_id.present? }
  validates :badge_id, uniqueness: {scope: [:start_date, :end_date]}

  validate :badge_is_nominatable

  scope :for_company, ->(company){ where(company_id: company.id) }

  def interval
    Interval.new(interval_id)
  end

  private

  def badge_is_nominatable
    if self.badge && !self.badge.is_nomination?
      errors.add(:badge, I18n.t('activerecord.errors.models.campaign.non_nomination_badge'))
    end
  end  

  def set_interval_from_badge
    if self.badge.present?
      self.interval_id = self.badge.sending_interval_id
    end
  end
end