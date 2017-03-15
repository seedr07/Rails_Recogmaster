FactoryGirl.define do
  factory :plan do |p|
    name "someplan"
    label "Some plan"
    interval "monthly"
    description "This plan is $1 per user"
    price_per_user 1
    is_public true
  end
  
  factory :business_plan, parent: :plan do |a|
    name "business200"
    label "Business 200"
    interval "monthly"
    description "$2.00 / user / month"
    price_per_user 2
  end

  factory :business_100_yearly_plan, parent: :plan do |a|
    name "business100Yearly"
    label "Business 1.00 / user / year"
    interval "yearly"
    description "$1.00 / user / year"
    price_per_user 1
    is_public false
  end

  factory :business_2400_yearly_plan, parent: :plan do |a|
    name "business2400Yearly"
    label "Business 24.00 / user / year"
    interval "yearly"
    description "$24.00 / user / year"
    price_per_user 24
  end  

  factory :business_0795_monthly_plan, parent: :plan do |a|
    name "business795monthly"
    label "Business 7.95 / user / month"
    interval "monthly"
    description "$7.95 / user / month"
    price_per_user 7.95
  end

  factory :business_0395_yearly_plan, parent: :plan do |a|
    name "business395yearly"
    label "Business 3.95 / user / year"
    interval "yearly"
    description "$3.95 / user / year"
    price_per_user 3.95
  end  

  factory :business_4680_yearly_plan, parent: :plan do |a|
    name "business4680yearly"
    label "Business 46.80 / user / year"
    interval "yearly"
    description "$46.80 / user / year"
    price_per_user 46.80
  end  
end