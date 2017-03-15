require 'spec_helper'

describe "Companies Settings Teams Toggle", js: true do
  describe "settings page" do
    before(:each) do
      @user = login_as(:company_admin)
      @company = @user.company
      visit company_path(network: @user.network)
      click_link("Settings")
    end

    it "should correctly toggle you stats" do
      expect(page).to have_selector('#settings', visible: true)
      expect(@company.allow_rewards?).to eq(true)
      page.execute_script('$("#settings #allow-rewards .iOSCheckContainer .on-off").click()')
      wait_until_ajax_completes
      @company.reload
      expect(@company.allow_rewards?).to eq(false)
    end

  end


  describe "navbar links" do
    before do
      @user = login_as(:company_admin)
    end

    context "on rewards" do
      before do
        turn_on_rewards
        visit redemptions_path(network: @user.network)
      end

      it "should show navbar link" do
        within("#header-controls") do
          expect(page).to have_content("Rewards")
        end
      end

      it "should show rewards" do
        expect(page).to have_content("Currently no rewards exist for #{@user.company.name}")
      end
    end

    context "off rewards" do
      before do
        turn_off_rewards
        visit redemptions_path(network: @user.network)
      end

      it "should not show navbar link" do
        within("#header-controls") do
          expect(page).to_not have_content("Rewards")
        end
      end

      it "should not show rewards" do
        expect(page).to_not have_content("Currently no rewards exist for #{@user.company.name}")
        expect(page).to have_content("You do not have permission to access that page. Go back to where you came from")
      end
    end
  end
end

def turn_on_rewards
  @user.company.update_attribute(:allow_rewards, true)
end

def turn_off_rewards
  @user.company.update_attribute(:allow_rewards, false)
end