require 'spec_helper'

describe Plan::Creator do
  let(:subscription) { FactoryGirl.create(:subscription) }
  let(:creator) { Plan::Creator.create!(subscription) }

  context "#create" do
    it "should create stripe plan from subscription" do
      expect{creator}.to change{Plan.count}.by(1)
    end
  end
end