class Redemption < ActiveRecord::Base
  acts_as_paranoid  

  belongs_to :reward, inverse_of: :redemptions
  belongs_to :user, inverse_of: :redemptions
  belongs_to :company, inverse_of: :redemptions
  has_many :point_activities, ->{ PointActivity.redemptions }, foreign_key: :activity_object_id, dependent: :destroy

  before_validation :ensure_company_id

  validates :reward_id, :user_id, :company_id, :points_at_redemption_time, presence: true
  validates :points_at_redemption_time, numericality: {only_integer: true, greater_than: 0}, allow_blank: true
  validate :reward_matches_company
  validate :reward_is_enabled
  validate :user_has_enough_points
  validate :is_within_interval

  after_commit :send_notifications, on: :create

  InvalidRedemption = Class.new(ActiveRecord::RecordInvalid)

  def self.redeem(user, reward)
    redemption = Redemption.new do |r|
      r.user = user
      r.reward = reward
      r.company = user.company
      r.points_at_redemption_time = user.redeemable_points
    end

    redemption.save

    return redemption
  end

  private
  def ensure_company_id
    self.company_id = self.user.company_id if self.user.present?
  end

  def reward_matches_company
    if reward && reward.company_id != self.company_id
      errors.add(:base, I18n.t('activerecord.errors.models.redemption.reward_matches_company', default: 'Reward does not appear to offered by your company'))
    end
  end

  def reward_is_enabled
    if reward && !reward.enabled?
      errors.add(:base, I18n.t('activerecord.errors.models.redemption.reward_is_enabled', default: 'Reward is not currently active and may not be redeemed'))
    end
  end

  def user_has_enough_points
    if user && (user.redeemable_points < reward.points)
      errors.add(:base, I18n.t('activerecord.errors.models.redemption.not_enough_points', default: 'Reward may not be redeemed because user does not have enough points'))
    end
  end

  def is_within_interval
    if reward.interval.present? && reward.frequency.present?
      if !reward.can_redeem_within_frequency?(user)
        errors.add(:base, I18n.t('activerecord.errors.models.redemption.is_within_interval', default: 'Reward has already been redeemed recently. Check back soon to see if you can redeem it.'))
      end
    end
  end

  def send_notifications
    RedemptionNotifier.notify_of_redemption(user, self).deliver
    RedemptionNotifier.notify_admin_of_redemption(user, self).deliver    
  end
end
