class SubscriptionsController < ApplicationController
  filter_access_to :show, :edit, :update, :destroy, attribute_check: true

  before_filter :prevent_multiple, only: [:new, :create]
  before_filter :checkout_verb, only: [:update]
  helper_method :coupon

  #the routing is kinda weird.  it works, but you're not really making a new subscription.  you're just being taken to an upgrade page
  def new
  end

  # {"utf8"=>"✓", "quantity"=>"500", "subscription"=>{"stripe_card_token"=>"[FILTERED]"}, "network"=>"poop.com"}
  def create
    @subscription = Subscription::Creator.create_and_purchase(current_user.company, current_user, params)

    # @subscription = current_user.create_subscription!(plan, coupon, subscription_params)
    redirect_path = @subscription.persisted? ?
                      subscription_path(@subscription, success: true) :
                      nil

    respond_with @subscription
  end

  def show
    @subscription = Subscription.find(params[:id])
    @next_invoice = @subscription.next_invoice
    @invoices = @subscription.invoices
    @show_contract = @subscription.contract_body.present?
  end
  
  def update
    @subscription = Subscription.find(params[:id])


    if @subscription.pending?
      @subscription.attributes = params[:subscription]
      @subscription.user_id = current_user.id

      @subscription.save_with_payment!
    else
      @subscription.update_card!(params[:subscription])
    end
    @next_invoice = @subscription.next_invoice
    @invoices = @subscription.invoices

    flash[:error] = "Could not #{checkout_verb} credit card" if @subscription.errors.present?
    flash[:notice] = "Subscription was successfully #{checkout_verb}d" unless @subscription.errors.present?

    respond_with @subscription, location: subscription_path(@subscription)
  end

  protected

  def checkout_verb
    @checkout_verb ||= @subscription.pending? ? "purchase" : "update"
  end
  helper_method :checkout_verb

  def plan
    Plan.find_by_name!("business200")
    # subscription_params.has_key?(:plan_id) ?
    #   Plan.find(subscription_params[:plan_id]) :
    #   params[:billing] || Plan.default(coupon)
  end
  
  def subscription_params
    params[:subscription] || {}
  end
  
  def coupon
    @coupon ||= Coupon.find_or_sync(params[:promotion] || params[:code] || params[:coupon])
  end
  
  def prevent_multiple
    subscription = (current_user.subscription || current_user.company.subscription)
    if subscription.present?
      redirect_to subscription_path(subscription)
    elsif current_user.subscribed_account?
      flash[:notice] = "You are already subscribed"
      redirect_to root_path
    end
  end
end