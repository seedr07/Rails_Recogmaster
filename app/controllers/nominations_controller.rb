class NominationsController < ApplicationController
  def index
    @nominations = Nomination
      .joins(campaign: :badge)
      .for_sender(current_user)
      .sort_by{|n| [-1*(n.is_awarded? ? 1 : 0), n.campaign.badge.short_name, -1*n.votes.by(current_user).size, n.recipient.label]}
      .uniq
      # .order("is_awarded DESC, badges.short_name, votes_count desc")
      # .distinct

  end

  def new
    @nomination_vote = NominationVote.new
  end

  def create
    @nomination_vote = Nomination.nominate(current_user, nomination_params)
    respond_with @nomination_vote, flash: {notice: t("nominations.has_been_sent")}, location: nominations_path
  end

  def new_chromeless
    @nomination_vote = NominationVote.new
    @pageName = "nomination"
    @jsClass = "Nomination"
    @user_team_map = current_user.company.user_team_map

    #@recipient = recipient_from_params

    render action: "new", layout: "application_chromeless"
  end

  private
  def nomination_params
    params.require(:nomination_vote).permit(:message, nomination: [:badge_id], recipients: [])
  end
end
