# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :recognition do
    badge_id {Badge.boss.id}
    sender_id {FactoryGirl.create(:active_user).id}
    recipients {[FactoryGirl.create(:active_user, email: (rand(1000).to_s+User.find(self.sender_id).email))]}
    message "MyText"

    factory :recognition_with_multiple_recipients do
      recipients { 3.times.map{FactoryGirl.create(:active_user, email: (rand(1000).to_s+User.find(self.sender_id).email))} }
    end
  end

  factory :recognition_with_approvals, parent: :recognition do |r|
    after(:create) do |r|
      r.approvals = [FactoryGirl.build(:recognition_approval, giver: FactoryGirl.create(:active_user, email: "asdfasd@#{r.recipients.first.company.domain}"))]
    end
  end

end
