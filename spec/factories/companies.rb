# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :company do
    name "Initech, Inc."
    domain {FactoryGirl.generate(:email).split("@")[1]}
  end
  factory :company_with_users, parent: :company do
    before(:create) do |c|
      c.users = [FactoryGirl.build(:active_user, email: "asdfasd@#{c.domain}")]
    end
    after(:create) do |c|
      c.users.each do |u|
        u.verify!
        u.set_status!(:active)  
      end
    end
  end
end
