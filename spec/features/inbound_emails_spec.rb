require 'spec_helper'

describe "InboundEmails", js: true do
  let(:mandrill_data) { MandrillInboundData.data }
  let(:event_hash) { JSON.parse(mandrill_data["mandrill_events"])[0] }

  context "when receiving inbound emails" do
    it "should have add user" do
      expect {
        InboundEmail.create!(data: event_hash) 
      }.to change{User.count}.by(1)
    end
  end

  context "when new sender" do
    let(:verify_url) { verify_signup_path(user.perishable_token) }
    let(:user) { User.last }

    before do
      @original_email_count = ActionMailer::Base.deliveries.length
      InboundEmail.create!(data: event_hash) 
      @original_recognition_count = Recognition.count
    end

    context "and sending another email before verifying account" do
      before do
        InboundEmail.create!(data: event_hash) 
      end

      it "sends recognition queued email" do
        expect(ActionMailer::Base.deliveries.length).to eq(@original_email_count + 2)
        last_email = ActionMailer::Base.deliveries.last
        expect(last_email.subject).to eq("Please verify your email to send your recognition")
        expect(last_email).to have_content(verify_url)

      end

      context "and then user clicks to verify link in email" do
        it "releases both recognitions" do
          visit verify_url
          expect(page.current_path).to eq(sign_up_path)

          fill_in "user_first_name", with: "Don"
          fill_in "user_last_name", with: "Corleone"
          within("form#full_name_form"){click_on "Next"}
          wait_until_ajax_completes
          sleep 1

          within("form#user_password_form") do
            fill_in "user_password", with: "abcdefg"
            click_on "Join"
          end
          wait_until_ajax_completes(60)
          sleep 0.5

          user.reload
          expect(page.current_path).to eq(welcome_path(network: user.network))            
          expect(page).to have_css("#welcome-wrapper")
  
          expect(user.status).to eq("active")
          expect(Recognition.count).to eq(@original_recognition_count + 2)

        end
      end
    end

    context "and clicking on verify link in email" do
      it "allows user to complete profile" do
        expect(ActionMailer::Base.deliveries.length).to eq(@original_email_count + 1)
        last_email = ActionMailer::Base.deliveries.last
        expect(last_email.subject).to eq("Please verify your email to send your recognition")
        expect(last_email).to have_content(verify_url)

        visit verify_url

        expect(page.current_path).to eq(sign_up_path)

        fill_in "user_first_name", with: "Don"
        fill_in "user_last_name", with: "Corleone"
        within("form#full_name_form"){click_on "Next"}
        wait_until_ajax_completes
        sleep 1

        within("form#user_password_form") do
          fill_in "user_password", with: "abcdefg"
          click_on "Join"
        end
        wait_until_ajax_completes
        sleep 0.5

        user.reload
        expect(page.current_path).to eq(welcome_path(network: user.network))            
        expect(page).to have_css("#welcome-wrapper")

        expect(user.status).to eq("active")
        expect(Recognition.count).to eq(@original_recognition_count + 1)
        expect(ActionMailer::Base.deliveries.length).to eq(@original_email_count + 3)
      end
    end
  end

  context "when existing sender but new recipient" do
    let(:verify_url) { verify_signup_path(user.perishable_token) }
    let(:user) { User.last }
    let(:recognition_url) { recognition_path(Recognition.first)}
    let(:recipient_email) { "rcp1@example1.com"}
    let(:recognition_link_text) { "View your recognition"}


    before do
      @user = FactoryGirl.create(:active_user, email: "example.sender@mandrillapp.com")
      @original_email_count = ActionMailer::Base.deliveries.length
      @original_recognition_count = Recognition.count
      InboundEmail.create!(data: event_hash) 
    end

    it "sends recognition" do
      expect(ActionMailer::Base.deliveries.length).to eq(@original_email_count + 2)
      recognition_email, confirmation_email = ActionMailer::Base.deliveries.last(2)
      expect(recognition_email).to_not have_content(verify_url)

      expect(Recognition.count).to eq(@original_recognition_count + 1)
      expect(recognition_email.subject).to eq("#{@user.full_name} recognized you!")
      expect(recognition_email.to).to eq([recipient_email])
      email_str = Capybara.string(recognition_email.body.encoded)
      expect(email_str).to have_content(recognition_link_text)
      expect(email_str.find_link(recognition_link_text)[:href]).to match(recognition_url)
      expect(email_str.find_link(recognition_link_text)[:href]).to match("invite=")
    end
  end

  context "when existing sender and existing recipient" do
    let(:verify_url) { verify_signup_path(user.perishable_token) }
    let(:user) { User.last }
    let(:recognition_url) { recognition_path(Recognition.first)}
    let(:recipient_email) { "rcp1@example1.com"}
    let(:recognition_link_text) { "Comment on this recognition"}

    before do
      @user = FactoryGirl.create(:active_user, email: "example.sender@mandrillapp.com")
      @recipient = FactoryGirl.create(:active_user, email: recipient_email)
      @original_email_count = ActionMailer::Base.deliveries.length
      @original_recognition_count = Recognition.count
      InboundEmail.create!(data: event_hash) 
    end

    it "sends recognition" do
      expect(ActionMailer::Base.deliveries.length).to eq(@original_email_count + 2)
      recognition_email, confirmation_email = ActionMailer::Base.deliveries.last(2)
      expect(recognition_email).to_not have_content(verify_url)

      expect(Recognition.count).to eq(@original_recognition_count + 1)
      expect(recognition_email.subject).to eq("#{@user.full_name} recognized you!")
      expect(recognition_email.to).to eq([recipient_email])
      email_str = Capybara.string(recognition_email.body.encoded)
      expect(email_str).to have_content(recognition_link_text)
      expect(email_str.find_link(recognition_link_text)[:href]).to match(recognition_url)
      expect(email_str.find_link(recognition_link_text)[:href]).to_not match("invite=")
    end
  end  

end