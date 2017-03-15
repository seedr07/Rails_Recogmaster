class WelcomeController < ApplicationController
  before_filter :send_to_subscription, only: [:show], if: ->{params.key?(:upgrade) && @company.subscription.present?}

  def show
    @recognitions = current_user.recognitions
    @integration = get_integration
    @step = params[:step]
    @purchase_value = purchase_value
    @purchase_integration_value = purchase_integration_value
    @youtube_id = "jayUjgU259U"
  end

  def save_user_count
    current_user.company.update_column(:requested_user_count, params[:user_count])
    current_user.company.delay(queue: 'priority').enable_custom_badges!  unless current_user.company.custom_badges_enabled?
    Recognize::Application.closeio.delay(queue: 'sales').upsert_contact(current_user)

    render nothing: true
  end

  protected

  def plan
    subscription_params.has_key?(:plan_id) ?
      Plan.find(subscription_params[:plan_id]) :
      params[:billing] || Plan.default(coupon)
  end

  def subscription_params
    params[:subscription] || {}
  end

  def coupon
    @coupon ||= Coupon.find_or_sync(params[:promotion] || params[:code] || params[:coupon])
  end

  def purchase_value
    if @integration == "office365"
      t("welcome.office365_value_prop")
    elsif @integration == "yammer"
      "If you recognize your staff your company will make more money. Be the one who does that."
    else
      t("welcome.standalone_value_prop")
    end
  end

  def purchase_integration_value
    if @integration == "office365"
      t("welcome.office365_integration_value_prop")
    elsif @integration == "yammer"
      "Yammer becomes a 1000x better"
    else
      t("welcome.standalone_integration_value_prop")
    end
  end

  def get_integration
    provider = current_user.authentications.last.try(:provider)
    if provider.in? ["office365", "sharepoint", "yammer"]
      if provider == "yammer"
        return "yammer"
      end
      return "office365"
    else
      return "standalone"
    end
  end

  def send_to_subscription
    redirect_to upgrade_path
  end
end
