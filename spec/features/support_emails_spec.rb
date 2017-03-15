require 'spec_helper'

describe "SupportEmails", js: true do

  before do
  end
  context "when viewing new support email page" do
    before do
      visit contact_path
    end
    
    it "should show the new support email form" do
      page.current_path.should == contact_path
      page.should have_field "support_email_name"
      page.should have_field "support_email_email"
      page.should have_field "support_email_message"
      
    end
    
    context "when submitting form with missing fields" do
      before do
        click_on "Send"
      end
      
      it "should show error messages" do
        page.should have_content "Name can't be blank"
        page.should have_content "Email can't be blank"
        page.should have_content "Message can't be blank"
      end
    end

    context "when submitting form all required fields" do
      before do
        @initial_support_email_count = SupportEmail.count
        fill_in "support_email_name", with: "Bob Barker"
        #oi capybara strikes again, need to specify id of field rather than just label
        fill_in "support_email_email", with: "bob@barker.com"
        fill_in "support_email_message", with: "Hello.  This is Bob reminding you to please have your pets spayed or neutered.  Thank."
        click_on "Send"
        wait_until_ajax_completes
      end
      
      it "should have saved support email" do
        SupportEmail.count.should == @initial_support_email_count + 1
      end
      
      it "should show success message" do
        page.current_path.should == contact_path
        page.should have_content("Success! We've received your inquiry. We'll get back to you shortly.")
      end
    end
  end
end