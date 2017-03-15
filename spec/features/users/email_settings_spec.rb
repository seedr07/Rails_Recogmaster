require 'spec_helper'

describe "Users EmailSettings", js: true do
  context "when updating email settings" do

    let!(:user) {login_as(:active_user)}

    before do
      visit edit_user_path(user)
    end
    
    it "should have basic notifications enabled" do
      page.should have_checked_field :user_email_setting_attributes_new_recognition
      page.should have_checked_field :user_email_setting_attributes_weekly_updates
      expect(page).to have_checked_field :user_email_setting_attributes_allow_sms_notifications
    end  
    
    it "should have global unsubscribe turned off" do
      page.should have_unchecked_field :user_email_setting_attributes_global_unsubscribe
    end  
    
    context "and turning off an individual notification" do
      before do
        uncheck :user_email_setting_attributes_new_recognition
        page.find(".button[value=Save]").click
        wait_until_ajax_completes        
      end
      
      it "should have saved the turning off of the notification" do
        page.should have_unchecked_field :user_email_setting_attributes_new_recognition
        user.reload.email_setting.new_recognition.should be_false        
      end
    end
    
    context "and turning on global unsubscribe" do
      before do
        check :user_email_setting_attributes_global_unsubscribe
        page.find(".button[value=Save]").click
        wait_until_ajax_completes                
      end
      it "should have saved the global unsubscribe and disabled the other notification checkboxes" do
        page.should have_checked_field :user_email_setting_attributes_global_unsubscribe
        user.reload.email_setting.global_unsubscribe.should be_true
        page.should have_selector ("#user_email_setting_attributes_new_recognition[disabled]")
        page.should have_selector ("#user_email_setting_attributes_weekly_updates[disabled]")
        
      end      
    end
  end
end