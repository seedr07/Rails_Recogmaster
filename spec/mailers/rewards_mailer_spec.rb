require 'spec_helper'

describe RedemptionNotifier do
  let(:company_admin) { FactoryGirl.create(:company_admin) }
  let(:company) { company_admin.company }
  let(:user) { FactoryGirl.create(:active_user, email: "#{FactoryGirl.generate(:count)}@#{company.domain}") }
  let(:reward) { FactoryGirl.create(:reward, company_id: company.id, points: 50) }
  let(:redemption) { Redemption.redeem(user, reward) }

  it "should send a confirmation email when a user redeems a reward" do
    # Send the email, then test that it got queued
    email = RedemptionNotifier.notify_of_redemption(user, redemption).deliver
    expect(ActionMailer::Base.deliveries).to_not be_empty
    last_email = ActionMailer::Base.deliveries.last

    expect(last_email.from).to eq(["donotreply@recognizeapp.com"])
    expect(last_email.to).to eq([user.email])
    expect(last_email.body.to_s).to include(reward.title)
  end

  it "should send an email to notify admin when a user redeemds a reward" do
    email = RedemptionNotifier.notify_admin_of_redemption(user, redemption).deliver
    expect(ActionMailer::Base.deliveries).to_not be_empty
    last_email = ActionMailer::Base.deliveries.last
    expect(last_email.from).to eq(["donotreply@recognizeapp.com"])
    expect(last_email.to).to_not eq([company_admin.email])
    expect(last_email.to).to_not eq([reward.manager])
    expect(last_email.body.to_s).to include(reward.title)
  end
end