# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :point_activity do
    recognition_id 1
    user_id 1
    company_id 1
    activity_type "MyString"
    amount 1
  end
end
