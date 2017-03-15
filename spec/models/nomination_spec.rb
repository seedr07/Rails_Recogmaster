require 'spec_helper'

describe Nomination do
  let(:vote) { Nomination.nominate(sender, params) }
  let(:nomination) { vote.nomination }
  let!(:sender) { FactoryGirl.create(:active_user) }
  let(:badge) { Badge.nominations.first || FactoryGirl.create(:nomination_badge) }
  let(:message) { "You're awesome"}
  let!(:params) {  Hashie::Mash.new({
    recipients: [recipient_param],
    message: message,
    nomination: {
      badge_id: badge.id,
    }
  }) }

  shared_examples_for "saveable_nomination" do |opts|
    it "should create nomination" do
      expected_vote_count = (opts && opts[:vote_count]) || 1

      nomination.reload
      expect(nomination).to be_persisted
      expect(nomination.campaign.badge).to eq(badge)
      expect(nomination.recipient).to eq(recipient)
      expect(nomination.recipient_company_id).to eq(recipient.company_id)
      expect(nomination.votes.size).to eq(expected_vote_count)
      expect(nomination.votes_count).to eq(expected_vote_count)
      expect(nomination.votes.last.message).to eq(message)
      expect(nomination.votes.last.sender_id).to eq(sender.id)
    end    

    it "should not send any emails" do
      expect{ Nomination.nominate(sender, params)}.to_not change{ActionMailer::Base.deliveries.size}
    end

    it "should not change points" do
      expect { Nomination.nominate(sender, params)}.to_not change{PointActivity.count}
    end
  end

  describe '#save with existing User recipient by email' do
    let(:recipient) { FactoryGirl.create(:active_user) }
    let(:recipient_param) { recipient.email }
    it_behaves_like "saveable_nomination"
  end

  describe '#save with existing User recipient by signature' do
    let(:recipient) { FactoryGirl.create(:active_user) }
    let(:recipient_param) {  "User:#{recipient.id}"}
    it_behaves_like "saveable_nomination"
  end

  describe '#save with Team by signature' do
    let(:recipient) { FactoryGirl.create(:team, company_id: sender.company_id) }
    let(:recipient_param) {  "Team:#{recipient.id}"}
    it_behaves_like "saveable_nomination"  
  end

  describe "#save with non-existing email" do
    let(:params) { Hashie::Mash.new({
      recipients: ["foo@foo.com"],
      message: message,
      nomination: {
        badge_id: badge.id,
      }
    }) }    

    it "should have errors on recipients" do
      expect(nomination).to_not be_persisted
      expect(nomination.errors.size).to eq(1)
      expect(nomination.errors[:sender_name]).to eq([I18n.t("activerecord.errors.models.nomination.recipient_unknown")])
    end
  end

  describe "#save with no recipients" do
    let(:params) { Hashie::Mash.new({
      message: message,
      nomination: {
        badge_id: badge.id,
      }
    }) }    

    it "should have errors on recipients" do
      expect(nomination).to_not be_persisted
      expect(nomination.errors.size).to eq(1)
      expect(nomination.errors[:sender_name]).to eq([I18n.t("activerecord.errors.models.nomination.recipient_or_email")])
    end    
  end

  describe "#save with multiple recipients" do 
    let(:user1) { FactoryGirl.create(:active_user) }
    let(:user2) { FactoryGirl.create(:active_user) }

    let(:params) { Hashie::Mash.new({
      recipients: [user1.email, user2.email],
      message: message,
      nomination: {
        badge_id: badge.id,
      }
    }) }    

    it "should have errors on recipients" do
      expect(nomination).to_not be_persisted
      expect(nomination.errors.size).to eq(1)
      expect(nomination.errors[:sender_name]).to eq([I18n.t("activerecord.errors.models.nomination.too_many_recipients")])
    end
  end

  describe "#save with existing nomination from same user" do
    let(:recipient) { FactoryGirl.create(:active_user) }
    let(:recipient_param) { recipient.email }

    before do
      @orig_sending_limit = badge.sending_frequency
      badge.update_column(:sending_frequency, 999)
      Nomination.nominate(sender, params.dup)
    end

    after do
      badge.update_column(:sending_frequency, @orig_sending_limit)
    end

    it_behaves_like "saveable_nomination", vote_count: 2

    it "should keep nomination and add vote" do
      nomination.reload
      expect(Nomination.count).to eq(1)
      expect(nomination.votes_count).to eq(2)
    end
  end

  describe "#save with existing nomination from different user" do
    let(:sender2) { FactoryGirl.create(:active_user) }
    let(:recipient) { FactoryGirl.create(:active_user) }
    let(:recipient_param) { recipient.email }

    before do
      Nomination.nominate(sender2, params.dup)
    end

    it_behaves_like "saveable_nomination", vote_count: 2

    it "should keep nomination and add vote" do
      nomination.reload
      expect(Nomination.count).to eq(1)
      expect(nomination.votes_count).to eq(2)
    end
  end

end