require 'spec_helper'

describe "Reports", type: :feature, js: true do
  let!(:user) { login_as(:active_user) }
  let(:team) {FactoryGirl.create(:team, company: user.company)}

  before do
    user.teams << team
  end

  describe '#index' do
    it 'loads page' do
      visit reports_path(network: user.network)
      expect(page).to have_content "Stats"
    end
  end
end