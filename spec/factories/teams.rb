# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :team do 
    name "Marketing#{Time.now.to_f.to_s}"
    company_id { FactoryGirl.create(:company, domain: FactoryGirl.generate(:count).to_s+".abc.com").id }
    created_by_id 1

    factory :team_with_users do
      before(:create) do |t|
        t.users = 2.times.map{|i| FactoryGirl.build(:active_user, email: "user#{i}-#{FactoryGirl.generate(:count)}@#{t.company.domain}")}
      end
    end
  end
end
