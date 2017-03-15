class RedemptionsController < ApplicationController
  filter_access_to :all, attribute_check: true, load_method: :current_user
  show_upgrade_banner only: [:index]

  def index
    @rewards = Reward.enabled.where(company_id: @company.id).order("points asc")
  end

  def create
    @reward = @company.rewards.find(params[:redemption][:reward_id])
    @redemption = Redemption.redeem(current_user, @reward)
    respond_with @redemption, onsuccess: {method: "fireEvent", params: {name: "updatedRewards", redeemable_points: current_user.redeemable_points}}
  end
end