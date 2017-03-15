FactoryGirl.define do
  factory :reward do
    title "Executive toilet"
    description "You can use the CEO's toilet, but just on Friday's"
    points 1000
    manager { FactoryGirl.create(:active_user) }
    company_id { manager.company_id }
  end
end