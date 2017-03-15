require 'spec_helper'

describe TeamManager do

  context "validations and associations" do

    subject { TeamManager.new }

    it { should validate_presence_of :manager_id }
    it { should validate_presence_of :team }
    it { should belong_to :team }
    it { should belong_to :manager }
  end

  context "adding managers" do
    let(:team) {FactoryGirl.create(:team) }

    it 'should not add manager from another company to team' do
      user = FactoryGirl.create(:active_user)
      tm = team.add_managers(user).first
      expect(tm.persisted?).to be_false
      expect(tm.errors[:manager_id]).to be_present
      expect(team.reload.managers).to_not include(user)
    end

    it 'should not add manager when user is already a manager of this team' do
      user = FactoryGirl.create(:active_user, email: "#{FactoryGirl.generate(:email_prefix)}@#{team.company.domain}")
      tm = team.add_managers(user)
      tm = team.add_managers(user).first
      expect(tm.persisted?).to be_false
      expect(tm.errors[:manager_id]).to be_present
      expect(team.reload.managers).to eq([user])
    end

    it 'should add manager to team' do
      user = FactoryGirl.create(:active_user, email: "#{FactoryGirl.generate(:email_prefix)}@#{team.company.domain}")
      tm = team.add_managers(user)
      expect(tm).to be_kind_of(Array)
      expect(tm.first.persisted?).to be_true
      expect(tm.first.errors[:manager]).to_not be_present
      expect(team.reload.managers).to include(user)
    end
  end

  context "removing managers" do
    let(:team) {FactoryGirl.create(:team) }

    it 'should remove manager' do
      user = FactoryGirl.create(:active_user, email: "#{FactoryGirl.generate(:email_prefix)}@#{team.company.domain}")
      team.team_managers.create(manager: user)
      expect(team.remove_managers(user)).to be_kind_of(Array)
      expect(team.reload.team_managers).to_not include(user)
    end
  end
end