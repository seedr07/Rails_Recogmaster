FactoryGirl.define do
  factory :email_setting do
    user_id 1
    global_unsubscribe true
    new_recognition true
    weekly_updates true
  end
end
