require 'spec_helper'

describe "Account", js: true do
  shared_context "starting sign in process" do
    let(:user) { FactoryGirl.create(:active_user) }

    before do 
      visit root_path 
      within "#login-menu" do
        click_on "Sign in"
      end
      expect(page).to have_css "#login-menu.open"
      within "#new_user_session" do
        fill_in "user_session_email", with: user.email
      end
      page.execute_script(%Q(var evt=jQuery.Event('blur');evt.target=$('#user_session_email')[0];$document.trigger(evt);))
      wait_until_ajax_completes
    end
  end

  describe 'Single Account' do
    include_context "starting sign in process"

    before do
      within "#new_user_session" do
        fill_in "user_session_password", with: "abcdef"
      end
      click_on "Go"
      # this could be one of the first tests to run on travis where this is no asset cache
      # and was timing out when building assets
      wait_until_page_is_redirected_from(root_path, 30) 
    end

    it "should be on stream page" do
      expect(page.current_path).to eq("/#{user.network}")
    end
  end

  describe 'Multiple Accounts' do
    let(:other_company) { FactoryGirl.create(:company, name: "AcmeCo") }

    before do 
      ExternalUserCreator.create(email: user.email, network: other_company.domain)
    end

    include_context "starting sign in process"

    it "should be on account chooser page" do
      expect(page.current_path).to eq(account_chooser_path)
    end    

    context "when selecting first company" do
      before do 
        click_on user.company.name
        wait_until_ajax_completes
        wait_until_page_is_redirected_from(account_chooser_path)
      end

      it "should be on companies idp page" do
        expect(page.current_path).to eq(identity_provider_path(network: user.company.domain))
      end
    end

    context "when selecting other company" do
      before do 
        click_on other_company.name
        wait_until_ajax_completes
        wait_until_page_is_redirected_from(account_chooser_path)
      end
      
      it "should be on companies idp page" do
        expect(page.current_path).to eq(identity_provider_path(network: other_company.domain))
      end

    end
  end
end