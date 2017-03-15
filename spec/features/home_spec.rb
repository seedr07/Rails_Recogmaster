require 'spec_helper'

describe "Home", js: true do
  describe "when accessing index action" do
    describe "and not logged in" do
      before(:each) do
        visit root_path
        page.execute_script("$('#original-homepage').removeClass('displayNone');")
      end

      it "should go to sales from pricing page from the top pricing nav link" do
        page.find('.nav.navbar-nav.navbar-right > li:nth-child(1) > a').click
        page.find('#intro > .inner:nth-of-type(1) > .button.button-big.button-primary:nth-of-type(1)').click
        expect(page).to have_content("Sales contact")
      end

      it "should show sales contact and submit" do
        page.find('#request-demo-top-action').click
        page.find('#support_email_name').set('ALex Grande')
        page.find('#support_email_email').set('grand@sfdsf.com')
        page.find('#support_email_phone').set('205394343')
        page.find('#support_email_message').set('I want to buy all the things you sell')
        page.find('.button.button-primary.button-large').click
        expect(page).to have_content("Success! We've received your inquiry. We'll get back to you shortly.")
      end

      # it "should show new user form" do
      #   page.should have_selector("form#new_user")
      # end

      it "should have a link to login" do
        page.should have_link("Sign in")
      end

    end

    describe "and logged in", js: true do
      before(:each) do
        @user = login_as(:active_user)
        visit root_path
      end
      
      it "should show stream page" do
        page.current_path.should == stream_path(network: @user.network)
      end
      
      it "should have link to log out" do
        page.should have_link("header-settings")        
      end
    end

  end
  
end