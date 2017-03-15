class CompanyAdmin::CampaignsController < CompanyAdmin::BaseController
  layout "company_admin"
  before_action :set_campaign

  def show
    @nominations = @campaign.nominations.sort_by{|n| [-1*n.votes_count, n.recipient.label]}
  end

  def archive
    @campaign.toggle!(:is_archived)
  end

  private
  def set_campaign
    @campaign = Campaign.find(params[:id])
  end
end