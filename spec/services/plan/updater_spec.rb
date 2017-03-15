require 'spec_helper'

describe Plan::Updater do
  let(:subscription) { FactoryGirl.create(:subscription) }

  context "#create" do
    it "should update plan from changes in subscription" do
      Plan::Creator.create!(subscription)

      subscription.amount = 999
      expect(subscription.save).to be_true
      
      plan = Plan::Updater.update!(subscription)
      plan.reload

      expect(plan.amount).to eq(999)
    end
  end
end