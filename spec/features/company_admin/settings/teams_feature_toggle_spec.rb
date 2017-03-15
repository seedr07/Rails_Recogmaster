require 'spec_helper'
include RecognitionsHelper

describe "Companies Settings TeamsToggle", js: true do
  describe "settings page" do
    before(:each) do
      @user = login_as(:company_admin)
      @company = @user.company
      visit company_path(network: @user.network)
      click_link("Settings")
    end

    it "should correctly toggle teams visibility setting" do
      expect(page).to have_selector('#settings', visible: true)
      expect(@company.allow_teams).to eq(true)
      page.execute_script('$("#settings #allow-teams-setting .iOSCheckContainer .on-off").click()')
      wait_until_ajax_completes
      @company.reload
      expect(@company.allow_teams).to eq(false)
    end
  end


  describe "stats page" do
    before do
      @user = login_as(:company_admin)
    end

    context "on" do
      before do
        turn_on_teams
        visit reports_path(network: @user.network)
      end

      it "should show teams" do
        expect(page).to have_content("Teams")
      end
    end

    context "off" do
      before do
        turn_off_teams
        visit reports_path(network: @user.network)
      end

      it "should not show teams" do
        expect(page).to_not have_content("Teams")
      end
    end
  end

  describe "user profile page" do
    before do
      @user = login_as(:active_user)
    end

    context "on" do
      before do
        turn_on_teams
        visit user_path(@user)
      end

      it "should show teams" do

        expect(page).to have_content("TEAMS")
      end
    end

    context "off" do
      before do
        turn_off_teams
        visit user_path(@user)
      end

      it "should not teams" do
        expect(page).to_not have_content("TEAMS")
      end
    end
  end

  describe "user profile edit page" do
    before do
      @user = login_as(:active_user)
    end

    context "on" do
      before do
        turn_on_teams
        visit edit_user_path(@user)
      end

      it "should show teams" do
        expect(page).to have_content("Teams Directory")
      end
    end

    context "off" do
      before do
        turn_off_teams
        visit edit_user_path(@user)
      end

      it "should not teams" do
        expect(page).to_not have_content("Teams Directory")
      end
    end
  end

  describe "fame page" do
    before do
      @user = login_as(:active_user)
      @user.company.update_attribute(:allow_hall_of_fame, true)
    end

    context "on" do
      before do
        turn_on_teams
        visit hall_of_fame_index_path(network: @user.network)
      end

      it "should show all company select list" do
        expect(page).to have_field "team_id"
        expect(page.all("#team_id option").first.text).to eq("All company")
        expect(page).to have_field "group_by"
        expect(page.all("#group_by option").first.text).to eq("Group by badge")
        expect(page.all("#group_by option").last.text).to eq("Group by team")
      end
    end

    context "off" do
      before do
        turn_off_teams
        visit hall_of_fame_index_path(network: @user.network)
      end

      it "should not show all company select list" do

        expect(page).to_not have_field "team_id"
        expect(page).to_not have_field "group_by"

      end
    end
  end

  describe "Stream page" do
    let(:team) { FactoryGirl.create(:team, company_id: @user.company_id) }

    before do
      @user = login_as(:active_user)
      @user.company.teams << team
    end


    context "on" do
      before do
        turn_on_teams
        visit stream_path(network: @user.network)
      end

      it "should show team list" do
        expect(page).to have_content("Teams")
        expect(page).to have_content(team.name)
      end
    end

    context "off" do
      before do
        turn_off_teams
        stream_path(network: @user.network)
      end

      it "should not show team list" do
        expect(page).to_not have_content("Teams")
        expect(page).to_not have_content(team.name)
      end
    end
  end

  describe "send recognition page" do
    let(:team) { FactoryGirl.create(:team, company_id: @user.company_id) }

    before do
      @user = login_as(:active_user)
      @recipient = FactoryGirl.create(:active_user, first_name: "Matt", last_name: "Haze", email: "Matthaze@#{@user.company.domain}")
      @user.refresh_cached_user_graph!

      @recipient.teams << team
    end

    context "on" do
      before do
        turn_on_teams
        visit new_recognition_path(network: @user.network)
      end

      it "should show teams next to names" do
        open_recognize_autocomplete
        expect(page).to have_content("#{team.name}")
      end

      it "should show teams when search for teams" do
        open_recognize_autocomplete(team.name)
        expect(page).to have_content("#{team.name}")
      end
    end

    context "off" do
      before do
        turn_off_teams
        visit new_recognition_path(network: @user.network)
      end

      it "should not show teams next to names" do
        open_recognize_autocomplete
        expect(page).to_not have_content("#{team.name}")
      end

      it "should not show teams when search for teams" do
        open_recognize_autocomplete(team.name)
        expect(page).to have_content("#{team.name}", count: 1)
      end
    end
  end
end

def turn_on_teams
  @user.company.update_attribute(:allow_teams, true)
end

def turn_off_teams
  @user.company.update_attribute(:allow_teams, false)
end

def open_recognize_autocomplete(value = "Matt Haze")
  page.execute_script("$('#recognition_recipient_name').focus().val('#{value}').keydown().keyup()")
  wait_until_ajax_completes
end