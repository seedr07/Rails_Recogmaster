require 'spec_helper'

describe Nominator do 
  let(:nominator) { Nominator.new(sender, params) }
  let(:sender) { FactoryGirl.create(:active_user) }
  let(:badge) { Badge.nominations.last || FactoryGirl.create(:nomination_badge) }
  let(:message) { "great job" }
  let(:recipient) { FactoryGirl.create(:active_user) }
  let(:recipient_param) { recipient.email }
  let(:params) { Hashie::Mash.new({
    recipients: [recipient_param],
    message: message,
    nomination: {
      badge_id: badge.id,
    }
  })}

  describe 'campaign exists?' do
    context "when campaign exists" do
      before do
        Campaign.create!(badge_id: badge.id, start_date: badge.sending_interval.start, end_date: badge.sending_interval.end, company_id: sender.company_id)
      end

      it "should return true" do
        expect(nominator.campaign_exists?).to be_true
      end
    end

    context "when campaign doesn't exist" do
      before do
        Campaign.create!(badge_id: badge.id, start_date: badge.sending_interval.start(shift: -1), end_date: badge.sending_interval.end(shift: -1), company_id: sender.company_id)
      end

      it "should return false" do
        expect(nominator.campaign_exists?).to be_false
      end
    end
  end

  describe ''
end