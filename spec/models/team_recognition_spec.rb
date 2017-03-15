require 'spec_helper'

describe Recognition do
  include RecognitionsHelper
  let(:team) { FactoryGirl.create(:team) }
  let(:badge) { Badge.user_badges.first }
  let(:user) { FactoryGirl.create(:active_user, email: "#{FactoryGirl.generate(:count)}@#{team.company.domain}")}
  let!(:sender) { FactoryGirl.create(:active_user) }
  context "when recognizing a team" do
    before do
      team.add_member(user)
    end

    it 'should send recognition' do
      mail_count = ActionMailer::Base.deliveries.length
      recognition = Recognition.new(badge: badge, sender: sender)
      recognition.add_recipient(team)
      expect(recognition.save).to be_true
      expect(recognition.reload.recipients.first).to eq(team)
      expect(ActionMailer::Base.deliveries.length).to eq(mail_count + team.users.length)
      expect(team.reload.total_team_points).to eq(badge.points)
      expect(team.reload.total_member_points).to eq(0)
      expect(recognition.recognition_recipients).to be_present
      expect(recognition.recognition_recipients.length).to eq(1)
      expect(recognition.recognition_recipients.first.team_id).to eq(team.id)
    end
  end

  context "when recognizing a member of a team" do
    before do
      team.add_member(user)
      user.reload
    end

    it 'should send recognition' do
      recognition = Recognition.new(badge: badge, sender: FactoryGirl.create(:active_user), message: "Yoyo")
      mail_count = ActionMailer::Base.deliveries.length
      recognition.add_recipient(user)
      expect(recognition.save).to be_true
      expect(recognition.reload.recipients.first).to eq(user)
      expect(ActionMailer::Base.deliveries.length).to eq(mail_count + 1)
      expect(team.reload.total_team_points).to eq(0)
      expect(team.reload.total_member_points).to eq(badge.points)
    end
  end
end