FactoryGirl.define do

  factory :subscription do |s|
    s.company { FactoryGirl.create(:company_with_users) }
    s.charge_interval Subscription::MONTHLY
    s.amount 500
    s.payment_method Subscription::CREDIT_CARD
    s.skip_signature_validation true

    factory :subscription_with_line_items do |swli|
      before(:create) do |s|
        s.line_items_attributes = {"1" => {amount: 500, description: "onboarding"}}
      end
    end
  end
end