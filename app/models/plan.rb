class Plan < ActiveRecord::Base
  has_many :subscriptions

  validates :name, uniqueness: true
  
  scope :active, -> { where(is_public: true) }
  scope :disabled, -> { where(is_public: false) }

  serialize :stripe_attributes

  def self.sync!
    return if Rails.env.test? && Recognize::Application.config.credentials["stripe"]["public_key"].blank?

    set = []
    Stripe::Plan.all(count: 100).data.each do |stripe_plan|
      set << stripe_plan.id
      sync_plan!(stripe_plan)
    end

    Rails.logger.debug "Set: #{set.inspect}"
    Plan.where(name: set).update_all(is_public: 1) if set.present?
    Plan.where.not(name: set).update_all(is_public: 0) if set.present?
  end

  def self.sync_plan!(stripe_plan)
    plan = Plan.where(name: stripe_plan.id).first_or_initialize
    plan.name = stripe_plan.id
    plan.label = stripe_plan.name
    plan.amount = stripe_plan.amount / 100
    plan.currency = stripe_plan.currency
    plan.description = stripe_plan.name
    plan.interval = stripe_plan.interval
    plan.stripe_attributes = stripe_plan.to_hash
    plan.save!    

    # pair to a matching subscription if possible
    subscription = Subscription
      .joins(:company)
      .where(companies: {domain: domain_from_stripe_plan_id(stripe_plan.id)})
      .first

    subscription.update_column(:plan_id, plan.id) if subscription
    return plan
  end

  def self.domain_from_stripe_plan_id(stripe_plan_id)
    stripe_plan_id.gsub(/\[.*\].*$/, '')
  end

  def self.user_tiers
    Plan.active.select{|p| p.price_per_user.blank?}.uniq{|p| p.min_users}.sort_by{|p| p.min_users.to_i}
  end

  def as_json(options={})
    options[:only] ||= [:id, :name, :label, :interval]
    options[:methods] ||= [:unit_price, :package, :min_users, :max_users, :interval_adverb, :interval_noun]
    super(options)
  end

  # supa hacky
  def old_tiered_plan?
    [/^Business/, /^Enterprise/].any?{|plan| name.match(plan)}
  end

  def package
    #FIXME: hacky hacky
    name.match(/^Business/) ? "Business" : "Enterprise"
  end

  def min_users
    user_count_match[1] rescue nil
  end

  def max_users
    user_count_match[2] rescue nil
  end
  
  def unit_price
    price_per_user || (stripe_attributes[:amount] / 100.0)
  end

  def interval_adverb
    return case interval
    when "month" then "monthly"
    when "year" then "yearly"
    else
      interval
    end

  end
  
  def interval_noun
    return case interval
    when "monthly" then "month"
    when "yearly" then "year"
    else
      interval
    end
  end
  
  def self.default(coupon=nil)
    if coupon
      coupon.plans.first
    else
      Plan.business_plan
    end
  end
  
  def self.valid_billing_type?(type)
    billing_types.include?(type.to_s)
  end
  
  def self.billing_types
    @billing_types ||= ["monthly", "yearly"]
  end
  
  def self.business_plan
    @business_plan ||= Plan.where(name: "BusinessMonthly_500_999_users").first
  end  

  def long_label
    self.label+"(#{self.description})"
  end

  private
  def user_count_match
    @user_count_match ||= description.match(/([0-9]*)\-([0-9]*)/)
  end
end