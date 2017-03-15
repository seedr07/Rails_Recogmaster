# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence :count do |n|
    n.to_s + Time.now.to_f.to_s.gsub('.','')
  end
  sequence :nextid do |n|
    (User.maximum(:id) + 1) rescue 1
  end
  sequence :email_prefix do |e|
    "email#{FactoryGirl.generate(:nextid)}_#{FactoryGirl.generate(:count)}"
  end
  sequence :email do |n|
    "email#{FactoryGirl.generate(:nextid)}_#{FactoryGirl.generate(:count)}@recognizeapp#{FactoryGirl.generate(:count)}.com"
  end
    
  factory :user do
    email {generate(:email)}
    first_name "User1"
    last_name "UserLastName1"
    password "abcdef"
    after(:create) do |u|
      u.company.update_attribute(:name, "Initech, Inc.")
    end
  end
  
  factory :active_user, parent: :user do
    after(:create) do |u|
      u.verify!
      u.set_status!(:active)      
    end
  end

  factory :company_admin, parent: :active_user do
    after(:create) do |u|
      u.roles = [Role.employee, Role.company_admin]
      u.company.update_attribute(:allow_admin_dashboard, true)
    end
  end

  factory :admin, parent: :active_user do
    after(:create) do |u|
      u.roles = [Role.employee, Role.admin]
    end
  end

  factory :director, parent: :active_user do
    after(:create) do |u|
      u.roles = [Role.employee, Role.director, Role.company_admin]
      u.company.update_attribute(:allow_admin_dashboard, true)
    end
  end

  factory :active_user_with_achievements_company, parent: :active_user do
    after(:create) do |u|
      u.company.update_attribute(:allow_achievements, true)
      u.company.enable_custom_badges!
      u.reload
      u.company.company_badges.last(2).each do |badge|
        badge.update_attributes(is_achievement: true, achievement_frequency: 5)
      end
    end
  end
end
