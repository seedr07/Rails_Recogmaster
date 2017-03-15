#  + A subscription is created by Recognize for a company
#  + If payment type is credit card, this creates a custom plan on Stripe
#  + This will then allow that company to pay via their billing tab
#  + If payment type is not credit card, invoices must be manually entered
class Subscription::Creator
  include Subscription::Common
  extend IntervalHelper

  PPU = 2
  YEARLY_DISCOUNT = 0.1

  attr_reader :company, :user, :params, :subscription

  def self.initialize_subscription(company, user)
    company.build_subscription(payment_method: Subscription::CREDIT_CARD)
  end

  def self.calculate_amount(quantity, interval)
    quantity = quantity.to_i
    if interval.yearly?
      quantity * PPU * 12 * (1 - YEARLY_DISCOUNT)
    else
      quantity * PPU
    end
  end

  #{
  # "utf8"=>"✓",
  # "subscription"=>{
  #   "contract_title"=>"Fefe Contract",
  #   "contract_body"=>"",
  #   "charge_interval"=>"Monthly",
  #   "amount"=>"300",
  #   "billing_label"=>"Fefe subscription $ / not set ",
  #   "department"=>"",
  #   "notes"=>"",
  #   "payment_method"=>"CreditCard",
  #   "status"=>"0",
  #   "billing_start_date"=>""
  #   },
  # "locale"=>"en-GB",
  # "company_id"=>"fefe.com"
  # }
  def self.create(company, user, params)
    new(company, user, params).create
  end

  def self.create_and_purchase(company, user, params)
    interval = Interval.new(params["subscription"].delete("interval"))
    subscription_params = params[:subscription].merge({skip_signature_validation: true})
    subscription_params[:contract_title] = "Contract for: "+user.company.domain
    subscription_params[:amount] = calculate_amount(params[:quantity], interval)
    subscription_params[:charge_interval] = reset_interval_adverb(interval).capitalize#{}"Monthly"
    subscription_params[:payment_method] = "CreditCard"
    subscription_params[:billing_label] = "#{user.company.domain} subscription"
    subscription_params[:user_count] = params[:quantity]

    subscription = nil
    begin
      Subscription.transaction do 
        subscription = self.create(company, user, subscription_params)
        subscription.user_id = user.id
        result = subscription.save_with_payment!
        raise ActiveRecord::Rollback unless result
      end
    rescue ActiveRecord::Rollback => e
    end

    return subscription
  end

  def create
    format_billing_start_date(params)
    transaction do
      @subscription = company.build_subscription(params)
      before_save
      @subscription.save!
      plan = Plan::Syncer.sync!(@subscription) unless @subscription.errors.present?
      @subscription.update_column(:plan_id, plan.id)
    end
    return @subscription
  rescue ActiveRecord::RecordInvalid => e
    return @subscription
  rescue => e
    @subscription.errors.add(:base, "Failed to save subscription: #{e.message}")
    return @subscription
  end

  private
  def format_billing_start_date(params)
    if params[:billing_start_date].present?
      params[:billing_start_date] = Date.strptime(params[:billing_start_date], "%m/%d/%Y")
    end
  end

end