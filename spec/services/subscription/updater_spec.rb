require 'spec_helper'

describe Subscription::Updater do
  let(:company) { subscription.company }
  let(:subscription) { FactoryGirl.create(:subscription) }
  let(:updater) { Subscription::Updater.update(company, User.new, params)}
  let(:params) { {amount: 999, charge_interval: Subscription::YEARLY} }

  before do
    Plan::Creator.create!(subscription)
  end

  describe '#update' do
    it 'should update attributes' do
      expect(updater).to be_kind_of(Subscription)
      expect(subscription.reload.amount).to eq(999)
      expect(subscription.plan.amount).to eq(999)
    end
  end
end