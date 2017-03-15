require 'spec_helper'

describe Reward do
  context "basic validation" do

    subject { Reward.new}

    it { should validate_presence_of :title }
    it { should validate_presence_of :description }
    it { should validate_presence_of :points }
    it { should validate_presence_of :manager_id }

  end

  context "associations" do
    let(:reward) { FactoryGirl.create(:reward)}

    it "should have company" do
      expect(reward.company).to be_kind_of(Company)
    end

    it "should have manager" do
      expect(reward.manager).to be_kind_of(User)
    end
  end

  context "setting interval and frequency" do

    context "when monthly" do 
      subject { Reward.new(frequency: 1, interval_id: Interval.monthly) }

      it "should be monthly interva|" do
        expect(subject.interval.monthly?).to be_true
      end
    end

    context "when no interval" do
      subject { Reward.new }

      it "should be null interva|" do
        expect(subject.interval.null?).to be_true
        expect(subject.interval.monthly?).to be_false
      end
    end
  end
end