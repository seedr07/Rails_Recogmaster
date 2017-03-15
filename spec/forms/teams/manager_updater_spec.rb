require 'spec_helper'

describe Teams::ManagerUpdater do
  before do 
    @team = FactoryGirl.create(:team)
    @managers = 2.times.map{FactoryGirl.create(:active_user, email: "#{FactoryGirl.generate(:email_prefix)}@#{@team.company.domain}")}
  end

  describe 'instantiation' do
    it 'sets team properly' do
      team = Team.new
      tmu = Teams::ManagerUpdater.new("team" => team)
      expect(tmu.team).to eq(team)
    end

    it 'sets people properly' do
      tmu = Teams::ManagerUpdater.new("people" => @managers.map(&:id))
      expect(tmu.people).to eq(@managers)
    end
  end

  describe 'saving' do

    before do
      @managers.each{|m| TeamManager.create(team: @team, manager: m)}
    end

    let(:updater) { Teams::ManagerUpdater.new("team" => @team, "people" => user_ids)}

    context 'removing managers' do
      let(:user_ids) { [@managers.first.id]}

      it 'removes managers' do
        expect{updater.save}.to change{TeamManager.count}.by(-1)
        expect(@team.reload.managers.length).to eq(1)
        expect(@team.managers).to eq(User.find(user_ids))
      end
      
    end

    context 'adding managers' do
      let(:user_ids) { [@managers.first.id, FactoryGirl.create(:active_user, email: "#{FactoryGirl.generate(:email_prefix)}@#{@team.company.domain}").id]}

      it 'adds managers specified' do
        expect{updater.save}.to change{TeamManager.count}.by(0) # remove 1, add 1
        expect(@team.reload.managers.length).to eq(2)
        expect(@team.managers).to eq(User.find(user_ids))        
      end      
    end

  end
end