require 'spec_helper'


describe "Companies - disabling of signups", js: true do
  def expect_to_show_idp_choices
    expect(page).to have_content "Sign in with Yammer"
  end

  
  include SignupSpecHelper
  Capybara::Session.send(:include, SignupSpecHelper::Session)
  include RecognitionsHelper
  Capybara::Session.send(:include, RecognitionsHelper::Session)

  let(:company) { FactoryGirl.create(:company_with_users) }
  let(:admin) { company.company_admins.first }
  let(:email) { "newuser111@#{company.domain}"}
  let!(:existing_user) { FactoryGirl.create(:active_user, email: "existinguser@#{company.domain}") }

  before do
    company.update_column(:disable_signups, true)
    setup_spec if respond_to?(:setup_spec)
  end

  it "should return false for disabled signups" do
    expect(company.disable_signups?).to be_true
  end

  describe 'Signing up from homepage' do

    before do 
      visit sign_up_path
      fill_in "user_email", with: email
      within "section#banner form" do
        click_on "Sign up"
      end
      wait_until_ajax_completes
    end

    it "should show error message that user is not allowed to sign up" do
      expect(page).to have_form_showing(:home)
      expect(page).to have_selector("div.error h5", count: 1)
      expect(page).to have_content("At the moment, only certain people are able to use Recognize in your company. Talk to your HR representative to find out more.")
    end
  end

  describe 'Recognizing new user' do
    before do
      login_as(:admin)
      visit new_recognition_path(network: company.domain)
      add_recipient(email)

      select_badge

      fill_in :recognition_message, with: "Great job man!"
      within("#recognition-submit-wrapper") { click_on "Recognize" }
      wait_until_ajax_completes
    end

    it "should show error messages on recipient email" do
      msg = "At the moment, only certain people are able to use Recognize in your company. Talk to your HR representative to find out more."
      page.should have_selector("div.error h5", text: msg)
    end    
  end

  describe 'Recognizing existing user' do

    before do
      login_as(:admin)
      visit new_recognition_path(network: company.domain)
      add_recipient(existing_user.email)

      select_badge

      fill_in :recognition_message, with: "Great job man!"
      within("#recognition-submit-wrapper") { click_on "Recognize" }
      wait_until_ajax_completes      
    end

    it "should send recognition" do
      assert_sent_recognition!      
    end
  end
end