require 'spec_helper'

def test_welcome_page
  page.should have_selector "#steps"
end

describe "PasswordResets", js: true do
  include SignupSpecHelper
  [SignupSpecHelper::Session, RecognitionsHelper::Session].each{|m| 
    Capybara::Session.send(:include, m)}
  
  
  before(:each) do    
    @user = FactoryGirl.create(:active_user)
  end
  
  context "when attempting to reset password" do
    before(:each) do
      visit password_resets_path
    end

    it "should render password resets form" do
      page.current_path.should == new_password_reset_path
      page.should have_content "Email address"
      page.should have_button "Reset my password"
    end
    
    context "when clicking reset password without an email address" do
      before(:each) do
        click_on "Reset my password"
      end
      
      it "should show error message prompting to enter email address" do
        page.should have_content "No user was found with that email address"
      end
    end

    context "when clicking reset password with a valid email address" do
      before(:each) do
        fill_in "email", with: @user.email
        click_on "Reset my password"
      end
      
      it "should show login page with appropriate flash message" do
        page.current_path.should == login_path
        page.should have_content "Instructions to reset your password have been emailed to you. Please check your email."
        page.should_not have_content "Looks like we have a small problem"
      end      
    end

    context "when visiting appropriate password reset url" do
      before(:each) do
        @user.reload
        visit edit_password_reset_path(@user.perishable_token)
      end
      
      it "should be on the reset password page" do
        page.current_path.should == edit_password_reset_path(@user.perishable_token)
        page.should have_field "New Password"
        page.should have_button "Update my password and log me in"
      end
      
      context "when submitting new password" do
        before(:each) do
          fill_in "New Password", with: "newpassword123"
          click_on "Update my password and log me in"
        end
        
        it "should be on stream page with welcome steps" do
          page.current_path.should == stream_path(@user.network)
          test_welcome_page()
        end
      end
    end
    
    context "when visiting an expired link" do
      before do
        old_token = @user.perishable_token
        @user.reset_perishable_token!
        visit edit_password_reset_path(old_token)
      end
      
      it "should be on the new password reset page" do
        page.current_path.should == new_password_reset_path
      end
      
      it "should show text telling user their link may be expired" do
        page.should have_content "This verification link has expired, please resubmit the password reset form"
      end
    end
  end
  
  context "when the first user for a company who hasnt yet set a password tries to reset it" do

    before do
      @user = User.new(email: FactoryGirl.generate(:email), first_name: "Mary", last_name: "Jane")
      @user.save!

      visit password_resets_path
      fill_in "email", with: @user.email
      click_on "Reset my password"
      wait_until_page_is_redirected_from password_resets_path

      @user.reload
      visit edit_password_reset_path(@user.perishable_token)

      fill_in "New Password", with: "newpassword123"
      click_on "Update my password and log me in"
      wait_until_page_is_redirected_from password_resets_path
            
    end

    it "should show stream page" do 
      page.current_path.should == stream_path(@user.network)
      test_welcome_page()
    end
  end

  context "when the first user for a new company has signed up, then logs out and tries to reset their password" do
    before do
      #reproduce what its like for a brand new company user
      visit root_path
      within("#navbar") { click_on "Sign up" }
      fill_in "user_email", with: FactoryGirl.generate(:email)
      within("form#new_user"){click_on "Sign up"}
      fill_in "user_first_name", with: "Bobs"
      fill_in "user_last_name", with: "Youruncle"
      within("form#full_name_form"){click_on "Next"}
      wait_until_ajax_completes(20)
      sleep 1
      within("form#user_password_form") do
        fill_in "user_password", with: "asdasdasd"
      end

      page.find("form#user_password_form button").click
      wait_until_ajax_completes(20)
      @user = User.last

      page.current_path.should == welcome_path(network: @user.network)
      page.should_not have_content "Login"
      visit logout_path
      
      visit password_resets_path

      fill_in "email", with: @user.email
      click_on "Reset my password"
      wait_until_page_is_redirected_from password_resets_path
      @user.reload
      visit edit_password_reset_path(@user.perishable_token)
      
    end

    it "and user does not enter password, it should be on the password reset page" do

      click_on "Update my password and log me in"
      wait_until_page_is_redirected_from password_resets_path

      page.current_path.should == password_reset_path(@user.perishable_token)
      page.should have_content "Sign in"
      @user.status.should == "active"
    end
    
    it "and user enters password, it should be on the stream page" do

      fill_in "New Password", with: "newpassword123"
      click_on "Update my password and log me in"
      wait_until_page_is_redirected_from password_resets_path

      page.current_path.should == stream_path(@user.network)
      page.should_not have_content "Sign in"
    end
    
  end
  
  context "when the non-first user for a company has not verified their email tries to reset their password" do

    before do
      @first_user = FactoryGirl.create(:active_user)
      @user = User.new(email: "blah@#{@first_user.company.domain}", first_name: "Riley", last_name: "Cat")
      @user.save!

      visit password_resets_path
      fill_in "email", with: @user.email
      click_on "Reset my password"
      wait_until_page_is_redirected_from password_resets_path

      @user.reload
      visit edit_password_reset_path(@user.perishable_token)

      fill_in "New Password", with: "newpassword123"
      click_on "Update my password and log me in"
      wait_until_page_is_redirected_from password_resets_path
    end

    it "should take them to the stream page" do
      page.should be_on_stream_page      
    end
  end
end