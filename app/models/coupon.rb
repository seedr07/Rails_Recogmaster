class Coupon < ActiveRecord::Base
  acts_as_paranoid
  
  attr_accessible :code, :message, :stripe_data, :css_class, :plan_ids

  validates :code, presence: true
  
  serialize :stripe_data 
  serialize :plan_ids
  
  delegate :percent_off, :amount_off, :max_redemptions, :times_redeemed, :valid, to: :stripe_data
  
  def as_json(options={})
    options[:only] ||= [:code]
    options[:methods] ||= [:percent_off ]
    super(options)
  end

  def self.sync_with_stripe!
    stripe_coupons = Stripe::Coupon.all.data
    stripe_coupons.each do |stripe_coupon|
      coupon = Coupon.find_or_initialize_by(code: stripe_coupon.id)
      coupon.stripe_data = stripe_coupon.as_json
      coupon.plan_ids = Plan.active.map(&:id).map(&:to_s) if coupon.plan_ids.blank?
      coupon.save!
    end
    recognize_coupons = Coupon.all
    recognize_coupons.each do |rc|
      unless stripe_coupons.any?{|sc| sc.id == rc.code}
        rc.destroy
      end
    end
  end
  
  # lookup will first check the Db
  # If not in db, check stripe
  # If in stripe, create AR and return it
  # This allows us to add coupons via stripe and not have to worry about it
  def self.find_or_sync(code)
    unless coupon = Coupon.find_by_code(code)
      stripe_coupon = Stripe::Coupon.retrieve(code) rescue nil
      if stripe_coupon
        coupon = Coupon.create!(code: stripe_coupon.id, stripe_data: stripe_coupon.as_json)
      else 
        coupon = nil
      end
    end
    return coupon
  end
  
  def expiration
    Time.at(stripe_data["redeem_by"]) rescue nil
  end
  
  def valid_for_use?
    !expired? && has_redemptions? && valid && !deleted_at
  end
  
  def has_redemptions?
    max_redemptions ? times_redeemed < max_redemptions : true
  end
  
  def expired?
    expiration ? expiration >= Time.now : false
  end

  def plans
    @plans ||= Plan.where(id: plan_ids)
  end

  def has_plan?(plan_or_id)
    pid = plan_or_id.respond_to?(:id) ? plan_or_id.id : plan_or_id
    plans.map{|p| p.id}.include?(pid.to_i)
  end
  private
  
  def stripe_data
    OpenStruct.new(read_attribute(:stripe_data))
  end  
end