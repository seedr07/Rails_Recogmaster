require 'spec_helper'
describe "Companies Settings NominationsToggle", js: true do
  describe "settings page" do
    before(:each) do
      @user = login_as(:company_admin)
      @company = @user.company
      visit company_path(network: @user.network)
      click_link("Settings")
    end

    it "should correctly toggle nomination setting" do
      expect(page).to have_selector('#settings', visible: true)
      expect(@company.allow_nominations?).to eq(false) #default is turned off for now
      page.execute_script('$("#settings #allow-nominations .iOSCheckContainer .on-off").click()')
      wait_until_ajax_completes
      @company.reload
      expect(@company.allow_nominations?).to eq(true)
    end    
  end
end