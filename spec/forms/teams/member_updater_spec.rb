require 'spec_helper'

describe Teams::MemberUpdater do
  before do 
    @team = FactoryGirl.create(:team)
    @members = 2.times.map{FactoryGirl.create(:active_user, email: "#{FactoryGirl.generate(:email_prefix)}@#{@team.company.domain}")}
    @badge = Badge.user_badges.first
  end

  describe 'instantiation' do
    it 'sets team properly' do
      team = Team.new
      tmu = Teams::MemberUpdater.new("team" => team)
      expect(tmu.team).to eq(team)
    end

    it 'sets people properly' do
      tmu = Teams::MemberUpdater.new("people" => @members.map(&:id))
      expect(tmu.people).to eq(@members)
    end
  end

  describe 'saving' do

    before do
      @members.each{|m| UserTeam.create(team: @team, user: m)}
      recognition
      @team.reload.update_all_points!
      @starting_points = @team.total_points
    end

    let(:updater) { Teams::MemberUpdater.new("team" => @team, "people" => user_ids)}

    context 'removing members' do
      let(:user_ids) { [@members.last.id]}
      let!(:recognition) { FactoryGirl.create(:recognition, recipients: @members.first.email) }

      it 'removes members' do
        expect{updater.save}.to change{UserTeam.count}.by(-1)
        expect(@team.reload.users.length).to eq(1)
        expect(@team.users).to eq(User.find(user_ids))
        expect(@team.total_points).to eq(@starting_points - @badge.points)
      end
      
    end

    context 'adding members' do
      let(:new_user) { FactoryGirl.create(:active_user, email: "#{FactoryGirl.generate(:email_prefix)}@#{@team.company.domain}") }
      let(:user_ids) { [@members.first.id, new_user.id]}
      let!(:recognition) { FactoryGirl.create(:recognition, recipients: new_user.email) }

      it 'adds members specified' do
        expect{updater.save}.to change{UserTeam.count}.by(0) # remove 1, add 1
        expect(@team.reload.users.length).to eq(2)
        expect(@team.users).to eq(User.find(user_ids))        
        expect(@team.total_points).to eq(@starting_points + @badge.points)
      end      
    end

  end
end