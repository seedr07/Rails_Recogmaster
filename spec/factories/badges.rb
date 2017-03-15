# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :badge do
    name "Cooperative#{Time.now.to_f.to_s.gsub('.','')}"
    short_name "Cooperative"
    long_name "Cooperative"
    description "MyText"
    image {File.open(Rails.root.join("app/assets/images/badges/200/#{name.gsub('_','-')}.png"))}
  end

  Badge::SET.each do |b|
    factory "#{b}_badge", class: Badge do
      name b.to_s
      short_name Badge::NAME_OVERRIDES.has_key?(b) ? Badge::NAME_OVERRIDES[b] : b.to_s.humanize
      long_name Badge::NAME_OVERRIDES.has_key?(b) ? Badge::NAME_OVERRIDES[b] : b.to_s.humanize
      description ""
      image {File.open(Rails.root.join("app/assets/images/badges/200/#{name.gsub('_','-')}.png"))}
    end
  end

  factory :custom_badge, class: "Badge" do
    short_name " Totally awesome Coolness Badge - #{Time.now.to_f.to_s.gsub('.','')}"
    company {FactoryGirl.create(:company)}
    image {File.open(Rails.root.join("app/assets/images/badges/200/cooperative.png"))}
  end

  factory :nomination_badge,class: "Badge" do
    name "NomsBadge#{Time.now.to_f.to_s.gsub('.','')}"
    short_name "NomsBadge#{Time.now.to_f.to_s.gsub('.','')}"
    image {File.open(Rails.root.join("app/assets/images/badges/200/cooperative.png"))}
    sending_interval_id Interval.daily.to_i
    sending_frequency 1
    is_nomination true
  end
end
