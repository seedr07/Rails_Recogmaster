require 'spec_helper'

describe "Achievement badges" do
  let(:badge_attrs) {
    { "name" => "funny", 
      "short_name" => "Funny", 
      "long_name" => "Funny Badge",
      "image" => File.open(Rails.root.join("app/assets/images/badges/200/cooperative.png")),
      "description" => "description" }
  }

  let(:company) { Company.new }
  let(:badge) {
    badge = Badge.new(badge_attrs)
    badge.stub(company: company, company_id: 1, is_achievement?: true)
    badge
  }

  describe "Permission" do

    it  "should allow achievements when achievements is activated" do
      company.stub(allow_achievements?: true)
      expect(badge.valid?).to be_true
    end

    it "should not allow achievement when achievements is not activated" do
      company.stub(allow_achievements: false)
      expect(badge.valid?).to be_false
      expect(badge.errors[:is_achievement]).to be_present
    end
  end

  describe "defaults" do 
    it "should show default value for interval to be quarterly" do
      expect(badge.interval).to be_kind_of(Interval)
      expect(badge.interval.quarterly?).to be_true
    end

    it "should show default value for frequency to be 10" do
      expect(badge.achievement_frequency).to eq(10)
    end

    it "should show achievements as false by default" do
      expect(Badge.new.is_achievement?).to be_false
    end

  end

  describe "validations" do
    before do
      company.stub(allow_achievements?: true)
    end

    it "should validate interval as a valid interval number" do

      badge.achievement_interval_id = 5
      expect(badge.valid?).to be_false
      expect(badge.errors[:achievement_interval_id]).to be_present

      badge.achievement_interval_id = Interval::MONTHLY
      expect(badge.valid?).to be_true

    end

    it "should validate frequency as a number" do
      badge.achievement_frequency = "aaa"
      expect(badge.valid?).to be_false
      expect(badge.errors[:achievement_frequency]).to be_present

      badge.achievement_frequency = 0
      expect(badge.valid?).to be_false
      expect(badge.errors[:achievement_frequency]).to be_present

      badge.achievement_frequency = -100
      expect(badge.valid?).to be_false
      expect(badge.errors[:achievement_frequency]).to be_present

      badge.achievement_frequency = 10
      expect(badge.valid?).to be_true

    end

    it "should not allow instant badge if achievement is activated" do
      badge.is_instant = true
      expect(badge.valid?).to be_false
      expect(badge.errors[:is_instant]).to be_present
    end

    it "should only allow managers to send achievement badge" do

    end

  end

end
