# Nominations will only be sent to existing users in the company
# This in contrast to Recognitions which will create and invite users if recipients 
# are specified by emails
class Nomination < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  include PostConcern
  include IntervalHelper

  belongs_to :recipient, polymorphic: true
  belongs_to :recipient_company, class_name: Company
  belongs_to :campaign, inverse_of: :nominations
  has_many :votes, class_name: NominationVote, dependent: :destroy do
    def by(user)
      where(nomination_votes: {sender_id: user.id})
    end
  end

  before_validation :set_recipient
  before_validation :set_company

  validates_associated :votes
  validate :check_recipient_or_email
  validate :only_one_recipient
  validate :badge_is_present

  # allow setting multiple recipients to be compatible with recognition form tools
  # validation will catch multiple recipients
  attr_accessor :recipients
  attr_accessor :badge_id # used for error messages for the form


  scope :for_recipient, ->(recipient){ where(recipient_id: recipient.id) }
  scope :for_sender, ->(sender){ joins(:votes).where(nomination_votes: {sender_id: sender.id})}
  scope :for_recipient_company, ->(company){ where(recipient_company_id: company.id) }

  def self.lookup_recipient(recipient)
    # TODO: HANDLE_MULTIPLE_NETWORKS
    #             ideally, this is specified by user
    #             However, if we support simple email address, we need to choose
    #             Although, we can draw the line that existing users must be specified via signature
    #             If raw email is sent, then it should be a new user added to the senders network
    #             And we should make switching between networks easier via an account chooser or something
    if recipient.blank?
      return nil
    elsif recipient.match(/\@/)
      user = User.find_by(email: recipient)
      return user
    elsif recipient.match(/\:/)
      return Nomination.find_recipient_from_signature(recipient)
    elsif recipient.kind_of?(User) || recipient.kind_of?(Team)
      return recipient
    else
      raise "Recipient not valid: #{recipient}"
    end
  end

  def badge
    campaign.badge
  end

  def self.nominate(sender, params)
    Nominator.nominate(sender, params)
  end

  private
  def badge_is_present
    unless campaign.present? && campaign.badge_id.present?
      errors.add(:badge_id, I18n.t('activerecord.errors.models.badge.blank'))
    end
  end

  def check_recipient_or_email
    if recipient_id.blank? 
      if recipients.blank?
        errors.add(:sender_name, I18n.t('activerecord.errors.models.nomination.recipient_or_email'))
      else
        errors.add(:sender_name, I18n.t('activerecord.errors.models.nomination.recipient_unknown'))
      end
    end
  end

  def only_one_recipient
    if recipients && recipients.length > 1
      errors.add(:sender_name, I18n.t('activerecord.errors.models.nomination.too_many_recipients'))
    end
  end

  def set_company
    self.recipient_company_id = recipient.company_id if self.recipient
  end

  def set_recipient
    unless self.recipients.blank?
      self.recipients.reject!(&:blank?) # housekeeping
      self.recipient = Nomination.lookup_recipient(self.recipients.first) 
    end
  end

end
