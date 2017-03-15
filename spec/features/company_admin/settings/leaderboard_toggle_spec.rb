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

    it "should correctly toggle you stats" do
      expect(page).to have_selector('#settings', visible: true)
      expect(@company.allow_you_stats?).to eq(true)
      page.execute_script('$("#settings #allow-you-stats .iOSCheckContainer .on-off").click()')
      wait_until_ajax_completes
      @company.reload
      expect(@company.allow_you_stats?).to eq(false)
    end

    it "should correctly toggle top user stats" do
      expect(page).to have_selector('#settings', visible: true)
      expect(@company.allow_top_employee_stats?).to eq(false)
      page.execute_script('$("#settings #allow-top-employee-stats .iOSCheckContainer .on-off").click()')
      wait_until_ajax_completes
      @company.reload
      expect(@company.allow_top_employee_stats?).to eq(true)
    end
  end


  describe "navbar links" do
    before do
      @user = login_as(:company_admin)
    end

    context "on you stats" do
      before do
        turn_on_you_stats
        turn_off_top_user_stats
        visit recognitions_path(network: @user.network)
      end

      it "should show navbar link" do
        within("#header-controls") do
          expect(page).to have_content("Stats")
        end
      end
    end

    context "on top user stats" do
      before do
        turn_off_you_stats
        turn_on_top_user_stats
        visit recognitions_path(network: @user.network)
      end

      it "should show navbar link" do
        within("#header-controls") do
          expect(page).to have_content("Stats")
        end
      end
    end

    context "off" do
      before do
        turn_off_you_stats
        turn_off_top_user_stats
        visit recognitions_path(network: @user.network)
      end

      it "should not show navbar link" do
        within("#header-controls") do
          expect(page).to_not have_content("Stats")
        end
      end
    end
  end


  describe "stats page" do
    before do
      @user = login_as(:active_user)
    end

    context "layout" do
      context "showing everything" do
        before do
          turn_on_you_stats
          turn_on_top_user_stats
          visit reports_path(network: @user.network)
        end

        it "should have span4 for 3 column layout" do
          within(".stats-columns-wrapper") do
            expect(page).to have_selector(".span4")
          end
        end
      end

      context "showing everything" do
        before do
          turn_off_you_stats
          turn_on_top_user_stats
          visit reports_path(network: @user.network)
        end

        it "should have span6 for 2 column layout" do
          within(".stats-columns-wrapper") do
            expect(page).to have_selector(".span6")
          end
        end
      end
    end

    context "on" do
      context "You stats" do
        before do
          turn_on_you_stats
          visit reports_path(network: @user.network)
        end

        it "should show you stats" do
          expect(page).to have_content("You")
        end

      end

      context "Top user stats" do
        before do
          turn_on_top_user_stats
          visit reports_path(network: @user.network)
        end

        it "should show top user stats" do
          expect(page).to have_content("Top users")
        end
      end
    end

    context "off" do
      context "You stats" do
        before do
          turn_off_you_stats
          visit reports_path(network: @user.network)
        end

        it "should not show you stats" do
          expect(page).to_not have_content("You")
          expect(page).to_not have_content("Teams")
        end

      end

      context "Top user stats" do
        before do
          turn_off_top_user_stats
          visit reports_path(network: @user.network)
        end

        it "should not show top user stats" do
          expect(page).to_not have_content("Top users")
        end
      end
    end
  end

end

def turn_on_top_user_stats
  @user.company.update_attribute(:allow_top_employee_stats, true)
end

def turn_off_top_user_stats
  @user.company.update_attribute(:allow_top_employee_stats, false)
end

def turn_on_you_stats
  @user.company.update_attribute(:allow_you_stats, true)
end

def turn_off_you_stats
  @user.company.update_attribute(:allow_you_stats, false)
end
