class Reward < ActiveRecord::Base
  include ActionView::Helpers::UrlHelper

  acts_as_paranoid  
  
  attr_accessible  :title, :description, :points, :company_id, :frequency, :interval_id, :manager_id, :image
  belongs_to :company
  belongs_to :manager, class_name: "User"

  has_many :redemptions, inverse_of: :reward

  validates :title, :description, :points, :manager_id, presence: true
  validates :points, numericality: {only_integer: true, greater_than: 0}, allow_blank: true
  validates :interval_id, inclusion: {in: Interval::RESET_INTERVALS_WITH_NULL.keys}
  validates :frequency, numericality: { only_integer: true, greater_than: 0, allow_blank: true}
  validates :frequency, presence: {message: "can't be blank if interval is specified."}, if: ->{interval_id.present?}
  scope :enabled, ->{ where(enabled: true)}

  mount_uploader :image, AttachmentUploader

  def redeemable_by?(user)
    redeemable = true
    redeemable &&= can_redeem_by_points?
    redeemable &&= can_redeem_within_frequency?(user)
    return redeemable    
  end

  def self.attributes_for_json
    [:id, :title, :description, :company_id, :points, :enabled, :url, :image]
  end

  def url
    Rails.application.routes.url_helpers.company_reward_url(self, network: self.network, host: Recognize::Application.config.host)
  end

  def network
    @network ||= self.company.domain
  end

  def interval
    @interval ||= Interval.new(interval_id)
  end

  def existing_redemptions_count_in_interval(user)
    user.redemptions.where(reward_id: self.id).where("created_at > ?", self.interval.start).size
  end 

  def can_redeem_within_frequency?(user)
    return true if self.interval_id.blank?
    existing_redemptions_count_in_interval(user) < self.frequency
  end

  def can_redeem_by_points?(user)
    user.redeemable_points >= self.points
  end
end