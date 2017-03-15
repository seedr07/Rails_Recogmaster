require 'spec_helper'

describe PointHistory do
  describe 'User' do

    context 'recording a users points' do
      let(:recognition) { FactoryGirl.create(:recognition) }
  
      it 'should create point history entry' do
        expect{PointHistory.record!(recognition.recipients.first)}.to change{PointHistory.count}.by(1)
        ph = PointHistory.last
        expect(ph.owner).to eq(recognition.recipients.first)
        expect(ph.points).to eq(recognition.badge.points)
        expect(ph.team_points).to eq(nil)
        expect(ph.member_points).to eq(nil)
      end
    end

    context 'recording a teams points' do
      let(:team) { FactoryGirl.create(:team_with_users) }
      let(:recognition) { FactoryGirl.create(:recognition, recipients: "Team:#{team.id}") }
  
      it 'should create point history entry' do
        expect{PointHistory.record!(recognition.recipients.first)}.to change{PointHistory.count}.by(1)
        ph = PointHistory.last
        expect(ph.owner).to eq(recognition.recipients.first)
        expect(ph.points).to eq(nil)
        expect(ph.team_points).to eq(recognition.badge.points)
        expect(ph.member_points).to eq(0)
      end
    end
  end
end