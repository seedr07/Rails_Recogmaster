# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :support_email do
    name "MyString"
    email "email@email.com"
    message "MyText"
  end
end
