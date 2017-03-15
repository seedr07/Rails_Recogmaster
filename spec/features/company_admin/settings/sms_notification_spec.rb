require 'spec_helper'

describe "Companies Settings SmsNotificationToggle", js: true do
  describe "settings page" do

    before(:each) do
      @user = login_as(:company_admin)
      @company = @user.company
      visit company_path(network: @user.network)
      click_link("Settings")
    end

    it "should correctly toggle allow sms notification" do
      expect(page).to have_selector('#settings', visible: true)
      expect(@company.allow_sms_notifications?).to eq(false)
      page.execute_script('$("#settings #allow-sms-notifications .iOSCheckContainer .on-off").click()')
      wait_until_ajax_completes
      @company.reload
      expect(@company.allow_sms_notifications?).to eq(true)
    end
  end
end
