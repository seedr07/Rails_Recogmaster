class EnsureSubscriptionsHaveProperPaymentMethodForStripe < ActiveRecord::Migration
  def up
    Subscription.all.each do |s|
      s.update_column(:status, Subscription::CURRENT) if s.active_stripe_subscription?
      s.update_column(:archived, true) if s.cancelled?
      s.update_column(:payment_method, Subscription::CREDIT_CARD) if s.active_stripe_subscription?
    end
  end
end
