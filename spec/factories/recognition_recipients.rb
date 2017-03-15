FactoryGirl.define do

  factory :recognition_recipient do |a|
    association :recognition, factory: :recognition
    association :user, factory: :active_user
  end

  
end