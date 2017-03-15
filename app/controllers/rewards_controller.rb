class RewardsController < ApplicationController

  def index
    @rewards = Reward.enabled.where(company_id: @company.id)
  end

  def create
    company_reward_params = reward_params.merge(:company_id => @company.id) 
    @reward = Reward.new(company_reward_params)
    @reward.save

    if handle_ie_stupidity?
      handle_ie_stupidity

    else
      respond_with @reward
    end

  end

  def update
    @reward = Reward.find(params[:id])
    @reward.update_attributes(reward_params)

    respond_with @reward

  end

  def destroy
    @reward = Reward.find(params[:id])
    @reward.update_column(:enabled, false)
  end

  private
  def reward_params
    params.require(:reward).permit(:title, :description, :points, :frequency, :interval_id, :manager_id, :image)
  end

  def handle_ie_stupidity?
    !request.headers["HTTP_ACCEPT"].match(/application\/json|application\/javascript/)
  end

  def handle_ie_stupidity
    request.format = 'json'

    resource = JsonResource.new(@reward, self, [], {})

    status = resource.has_errors? ? 422 : 200
    render :json => resource.to_json, :content_type => "text/plain", status: status

  end
end