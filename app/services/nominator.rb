# NOTE: this is the main entry point for "nominating"
#       What this really means is that you are voting for someone
#       When a vote comes in we need to figure out if there is
#       an existing nomination to apply the vote to. 
#       Further, nominations are grouped by campaigns, so
#       that is the first step: is there a campaign for this vote
#       All of this will be wraped
class Nominator
  
  attr_accessor :sender, :params, :vote

  def self.nominate(sender, params)
    new(sender, params).nominate
  end

  def initialize(sender, params)
    @sender = sender
    @params = params.dup
    @vote = NominationVote.new
  end

  def badge
    Badge.cached(badge_id)
  end

  def badge_id
    params[:nomination][:badge_id]    
  end

  def campaign
    @campaign ||= Campaign.find_by(badge_id: badge.id, start_date: campaign_start_date, end_date: campaign_end_date)
  end

  # badge and time period
  def campaign_exists?
    badge_id.present? && campaign.present?
  end

  # Campaign start/end dates are relative to the time of sending(now) and the badge interval
  def campaign_start_date
    badge.sending_interval.start
  end

  def campaign_end_date
    badge.sending_interval.end
  end

  def campaign_status_open?
    # FIXME: not sure why Steve and I spec'd this out
    #        but leaving here until we figure a use out for it
    #        Perhaps, this could be used to allow admins to close
    #        a contest early. Perhaps this checks the campaign has been archived
    true
  end

  def create_campaign
    @campaign = Campaign.create!(
      badge_id: badge.id, 
      company_id: sender.company_id,
      start_date: campaign_start_date, 
      end_date: campaign_end_date)
  end

  def error(msg)
    vote.errors.add(:base, msg)
  end

  def nominate
    if campaign_exists?
      if campaign_status_open?
        record_vote
      else
        error("This campaign is closed")
      end
    else
      create_campaign if badge_id.present?
      record_vote
    end
    
    return vote
  end

  def record_vote
    recipient_param = params && params[:recipients] && params[:recipients].reject(&:blank?).try(:first)
    recipient = Nomination.lookup_recipient(recipient_param)
    recipient_id = recipient.try(:id)

    badge_id = params[:nomination][:badge_id]

    self.vote = NominationVote.new(sender: sender)
    if recipient_id.present?
      nomination = Nomination.where(recipient_id: recipient_id, recipient_type: recipient.try(:class), campaign_id: campaign.id).first_or_initialize
    else
      nomination = Nomination.new
      nomination.campaign_id = campaign.id if badge_id.present?
    end

    nomination.recipients = params.delete(:recipients)
    params.delete(:nomination)

    self.vote.nomination = nomination
    self.vote.assign_attributes(params)
    self.vote.save
    
    return self.vote    
  end

end