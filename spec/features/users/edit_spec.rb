require 'spec_helper'

###############################################################
#
# When editing user profile
#
###############################################################
describe "Users", js: true do  
  context "when editing a user profile" do
    before do
      @user = login_as(:active_user, "abcd", redeemable_points: 1000000)
      visit edit_user_path(@user)
    end
  
    it "should show edit profile page" do
      page.current_path.should == edit_user_path(@user)
      page.should have_content "Edit Profile"
    end
  
    it "should save information when save is clicked" do
      fill_in "Job Title", with: "CEO"
      page.find(".button[value=Save]").click
      wait_until_ajax_completes
      @user.reload.job_title.should == "CEO"
    end
  
    it "should show error if a new password is entered without the original password" do
      fill_in "user_password", with: "newpassword123"
      page.find(".button[value=Save]").click
      wait_until_ajax_completes
      page.current_path.should == edit_user_path(@user)
      page.should_not have_content "Successfully updated profile"
      page.should have_content "Original password must be included to change your password"
    end
  
    it "should show edit page after successfully changing password" do
      fill_in "user_original_password", with: "abcdef"
      fill_in "user_password", with: "newpassword123"
      page.find(".button[value=Save]").click
      wait_until_ajax_completes
      page.current_path.should == edit_user_path(@user)
      page.should have_content "Successfully updated profile"
    end

    context "phone" do
      before do
        Recognize::Application.stub(twilio_client: Recognize::Application.twilio_test_client)        
      end
      it "should have phone with empty value" do 
        expect(page.find("#user_phone")[:value]).to be_nil
      end

      it "should update phone number" do 
        page.find("#user_phone").set("1 (516) 449-1234")
        page.find(".button[value=Save]").click
        wait_until_ajax_completes
        expect(page.find("#user_phone")[:value]).to eq("+15164491234")
      end

      it "should not update invalid phone number" do 
        page.find("#user_phone").set("(xxx) 449-1234")
        page.find(".button[value=Save]").click
        wait_until_ajax_completes
        expect(page).to have_content("Phone is invalid")
      end

    end

    context "language" do

      it "should update classname on body when changed to a long language (french)" do
        within "#header-loggedin-logo" do
          expect(page).to have_content("Recognize")
        end
        expect(page).to_not have_selector("body.long-language")
        select "French", from: "user[locale]"
        find(".button.button-primary").click
        wait_until_ajax_completes

        within "#header-loggedin-logo" do
          expect(page).to have_content("Reconnaissance")
        end

        expect(page).to have_selector("body.long-language")
      end

      it "should update recognize to recognise when changed to en-GB" do
        within "#header-loggedin-logo" do
          expect(page).to have_content("Recognize")
        end
        select "Great Britain English", from: "user[locale]"
        find(".button.button-primary").click
        wait_until_ajax_completes
        within "#header-loggedin-logo" do
          expect(page).to have_content("Recognise")
        end
      end

    end

  end
end