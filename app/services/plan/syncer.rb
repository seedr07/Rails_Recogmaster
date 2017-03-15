module Plan::Syncer
  attr_reader :subscription

  def self.sync!(subscription)
    if plan_exists?(subscription)
      Plan::Updater.update!(subscription)
    else
      Plan::Creator.create!(subscription)
    end
  end

  def self.plan_exists?(subscription)
    Stripe::Plan.retrieve(subscription.stripe_plan_id) rescue nil
  end
end