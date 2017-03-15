require 'spec_helper'

describe Subscription::Creator do
  let(:user) { FactoryGirl.create(:active_user) }
  let(:company) { user.company }
  let(:payment_method) { Subscription::CREDIT_CARD }
  let(:billing_start_date) { nil }
  let(:creator) { Subscription::Creator.new(company, user, params) }
  let(:subscription) { creator.create }
  let(:params) { 
    {amount: 500, charge_interval: Subscription::MONTHLY, payment_method: payment_method, billing_start_date: billing_start_date}.
    merge(additional_params)
  }
  let(:additional_params) { {} }

  context "when missing required attributes" do
    let(:params) { {} }
    it "should have errors on the subscription object" do
      expect(subscription.errors).to be_present
      expect(subscription.errors.size).to eq(3)
      expect(subscription.errors[:amount]).to be_present
      expect(subscription.errors[:charge_interval]).to be_present
      expect(subscription.errors[:billing_start_date]).to be_present
    end

    context "when its a wire payment" do
      let(:params) { {amount: 500, charge_interval: Subscription::MONTHLY, payment_method: Subscription::WIRE} }
      it "should have errors on the subscription object" do
        expect(subscription.errors).to be_present
        expect(subscription.errors.size).to eq(1)
        expect(subscription.errors[:billing_start_date]).to be_present
      end      
    end
  end

  context "when all required attributes are present" do
    context "when not credit card" do
      let(:payment_method) { Subscription::WIRE }
      let(:billing_start_date) { Time.now.strftime("%m/%d/%Y") }

      it "should save subscription" do
        expect(subscription).to be_persisted
      end
    end

    context "when credit card" do
      it "should save subscription" do
        expect(subscription).to be_persisted
        expect(subscription.status).to eq(Subscription::PENDING)
      end

      it "should create an plan with stripe" do
        expect{subscription}.to change{Plan.count}.by(1)
        expect(subscription.plan_id).to eq(Plan.last.id)
      end      

      context "when line items are present" do
        let(:additional_params) { {line_items_attributes: {1 => {amount: 500, description: "onboarding"}}}}

        it "should save subscription and create line items" do
          expect{
            expect(subscription).to be_persisted
          }.to change{LineItem.count}.by(1)
        end
      end
    end

  end

end