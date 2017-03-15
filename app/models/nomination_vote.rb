class NominationVote < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  include IntervalHelper

  belongs_to :nomination, counter_cache: :votes_count, validate: true
  belongs_to :sender, class_name: User
  belongs_to :sender_company, class_name: Company

  before_validation :set_sender_company

  validates :sender_id, :nomination, presence: true
  validates :sender_company_id, presence: true, if: ->{ sender_id.present? }
  validate :is_within_sending_limits, on: :create
  validate :message_is_required

  scope :sent_by, ->(sender) { where(sender_id: sender.id) }
  def self.for_company(company)
    where(sender_company_id: company.id)
  end

  def badge
    self.nomination.campaign.try(:badge)
  end

  private
  def set_sender_company
    self.sender_company_id = self.sender.company_id if self.sender
  end

  def is_within_sending_limits
    if badge.present? && badge.sending_frequency.present? && badge.sending_frequency.to_i > 0
      is_within_badge_sending_limits
    elsif sender && sender.company.recognition_limit_frequency.present? && sender.company.recognition_limit_frequency.to_i > 0
      is_within_company_sending_limits
    end
  end

  def is_within_badge_sending_limits
    start_time = badge.sending_interval.start
    interval_sent_nominations = sender.sent_nomination_votes.joins(nomination: :campaign).where("nomination_votes.created_at >= ? AND campaigns.badge_id = ?", start_time, badge.id)
    if interval_sent_nominations.size >= badge.sending_frequency
      err =  I18n.t('activerecord.errors.models.recognition.is_within_badge_sending_limits',
                        frequency: pluralize(badge.sending_frequency, 'time', 'times'),
                        interval: reset_interval_noun(badge.sending_interval))
      self.errors.add(:base, err) unless self.errors[:base].include?(err)
    end
  end

  def is_within_company_sending_limits
    start_time = sender.company.recognition_limit_interval.start
    interval_sent_nominations = sender.sent_nomination_votes.joins(:nomination).where("nomination_votes.created_at >= ?", start_time)
    if interval_sent_nominations.size >= sender.company.recognition_limit_frequency
      err =  I18n.t('activerecord.errors.models.recognition.is_within_company_sending_limits', interval: reset_interval_noun(sender.company.recognition_limit_interval))
      self.errors.add(:base,err) unless self.errors[:base].include?(err)
    end
  end

  def message_is_required
    if sender && sender.company.nomination_message_is_required? && message.blank?
      self.errors.add(:message, I18n.t('activerecord.errors.messages.blank'))
    end
  end      
end