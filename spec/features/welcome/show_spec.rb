require 'spec_helper'

describe "Welcome", js: true do
  context "Yammer" do
    before(:each) do
      WelcomeController.any_instance.stub(:get_integration).and_return("yammer")
      @user = FactoryGirl.create(:active_user)
      login_as(@user)
      visit welcome_path(network: @user.company.domain)
    end

    it "should show browser download" do
      expect(page).to have_content("Safari")
      expect(page).to have_selector(".browsers")
    end
  end

  context "Sign up" do
    before(:each) do
      @user = FactoryGirl.create(:active_user)
      login_as(@user)
      visit welcome_path(network: @user.company.domain)
    end

    it "should show onboarding info" do
      expect(page).to have_content("Why Recognize")
      expect(page).to have_content("How Recognize works")
    end

    it "should show payment form" do
      page.find('.button.button-large.button-primary.slideable-trigger').click
      expect(page).to have_content("How many users do you have?")
      expect(page).to_not have_content("How Recognize works")
      page.find('#user_count').set('1000')
      page.find('#user_count_submit').click
      wait_until_ajax_completes(20)
      expect(page).to have_content("$2000.00/mo for 1000 users")
      @user.reload
      expect(@user.company.requested_user_count).to eq(1000)
      expect(@user.company.custom_badges_enabled?).to be_true
    end

    it "should not submit user count if no value is given" do
      page.find('.button.button-large.button-primary.slideable-trigger').click
      page.find('#user_count_submit').click
      expect(page).to have_content("How many users do you have?")
    end

    it "should submit cc" do
      expect(@user.company.allow_admin_dashboard?).to be_false
      page.find('.button.button-large.button-primary.slideable-trigger').click
      page.find('#user_count').set('3')
      page.find('#user_count_submit').click
      page.find('.card-number').set('4242424242424242')
      page.find('.card-cvc').set('123')
      page.find('.card-expiry-month').set('12')
      page.find('.card-expiry-year').set('2018')
      page.find('#submit-button').click
      #CRAZYTIMEOUT: crazy timeout, remove eventually if capybara-webkit ever gets its act together
      wait_until_ajax_completes(300)
      expect(page).to have_content("Congratulations!")
      @user.reload
      expect(@user.company.allow_admin_dashboard?).to be_true
    end

    it "should show tour information on app pages" do
      page.find('#header-stream').click
      expect(page).to have_content("Increases staff engagement by 800%")
    end

    it "should take you to user count from app pages" do
      page.find('#header-reporting').click
      page.find(".upgrade-banner .button.button-highlight").click
      page.find('#user_count').set('100')
      page.find('#user_count_submit').click
      expect(page).to have_content("$200.00/mo for 100 users")
    end
  end

  context "Tour" do
    before do
      @user = FactoryGirl.create(:active_user)
      login_as(@user)
    end

    context "Video" do
      it "should show video iframes on rewards, stats, and company admin" do
        visit redemptions_path(network: @user.network)
        page.html.match("//www.youtube.com/iframe_api") != nil

        visit reports_path(network: @user.network)
        page.html.match("//www.youtube.com/iframe_api") != nil

        visit company_path(network: @user.network)
        page.html.match("//www.youtube.com/iframe_api") != nil

        visit stream_path(network: @user.network)
        page.html.match("//www.youtube.com/iframe_api") == nil
      end
    end


    it "should show value props for stream page" do
      visit stream_path(network: @user.network)
      expect(page).to_not have_selector("iframe#youtube-video")
      expect(page).to have_selector(".value-props")
    end

    it "should not show any upgrade banner on send recognition page and user profile" do
      visit new_recognition_path(network: @user.network)
      expect(page).to_not have_selector(".upgrade-banner")
      visit user_path(@user)
      expect(page).to_not have_selector(".upgrade-banner")
    end
  end
end