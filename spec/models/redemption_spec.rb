require 'spec_helper'

RSpec::Matchers.define :be_redeemed do |expected|
  match do |redemption|
    expected_redeemable_point_total = expected || -reward.points

    expect(redemption.persisted?).to be_true
    last_point_activity = PointActivity.last
    expect(last_point_activity.amount).to eq(-reward.points)
    expect(last_point_activity.is_redeemable).to be_true

    # NOTE: redeemable points are fully recalculated rather than increment/decrement
    #       so points should not be modified manually, they should go through some api.
    expect(user.reload.redeemable_points).to eq( expected_redeemable_point_total)
  end
end

describe Redemption do
  let(:user) { FactoryGirl.create(:active_user, redeemable_points: starting_points) }
  let(:reward) { FactoryGirl.create(:reward, company_id: user.company_id, points: 50) }
  let(:starting_points) { 100 }
  let(:redemption) { Redemption.redeem(user, reward) }

  describe 'Associations' do
    let(:redemption) { FactoryGirl.create(:redemption, user_id: user.id, reward_id: reward.id) }

    it "should belong to a user" do
      expect(redemption.user).to be_kind_of(User)
      expect(redemption.user.redemptions[0]).to be_kind_of(Redemption)
    end
  end

  describe 'Redeeming' do

    context 'when user does not have enough points' do
      let(:starting_points) { 0 }

      it "should not save and have errors" do 
        expect(redemption.persisted?).to be_false
        expect(redemption.errors.size).to_not eq(0)
        expect(redemption.errors[:base]).to eq(["Reward may not be redeemed because user does not have enough points"])
      end
    end

    context 'when user has enough points' do

      it "should save redemption" do 
        expect(redemption).to be_redeemed
      end      
    end
  end

  context "when reward has a frequency and interval set" do
    let(:reward) { FactoryGirl.create(:reward, company_id: user.company_id, points: 50, frequency: 1, interval_id: Interval.daily.interval_code) }

    context "and user has not redeemed within the interval" do
      it "should be redeemed" do
        expect(redemption).to be_redeemed
      end
    end

    context "and user has already redeemed within the interval" do

      before do
        Redemption.redeem(user, reward)
        user.update_column(:redeemable_points, 10000)
      end

      it "should not be redeemed" do
        expect(redemption).to_not be_redeemed
        expect(redemption.errors[:base]).to eq(['Reward has already been redeemed recently. Check back soon to see if you can redeem it.'])
      end

      context "and then in the next interval" do
        it "should redeem reward" do
          Timecop.freeze(2.days.from_now)
          redemption = Redemption.redeem(user, reward)
          expect(redemption).to be_redeemed(-100)
        end
      end
    end
  end
end