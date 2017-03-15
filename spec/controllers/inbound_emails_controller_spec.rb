require 'spec_helper'

describe InboundEmailsController do
  let(:mandrill_data) { MandrillInboundData.data }
  let(:mandrill_events) { JSON.parse(mandrill_data["mandrill_events"]) }

  context "when events are inbound" do
    it "saves inbound emails" do
      post :create, mandrill_data
      expect(response.status).to eq 200
      emails = assigns(:inbound_emails)
      expect(emails).to be_kind_of(Array)
      expect(emails.all?{|e| e.kind_of?(InboundEmail)}).to be_true
      expect(emails.all?{|e| e.data.kind_of?(Hash)}).to be_true
      expect(emails.all?{|e| e.persisted?}).to be_true
      expect(emails.all?{|e| e.status == InboundEmail::UNPROCESSED}).to be_true
    end
  end

  context "when events are not inbound" do
    it "does not save inbound emails" do
      data = mandrill_data.deep_dup      
      data["mandrill_events"].gsub!(/inbound/,'notinbound')
      expect {
        post :create, data
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  context "when there are no proper recipients" do
    it "does not send any recognitions" do
      FactoryGirl.create(:active_user, email: "example.sender@mandrillapp.com")
      data = mandrill_data.deep_dup      
      data["mandrill_events"].gsub!(/example1.com/,InboundEmail::INBOUND_DOMAIN)
      data["mandrill_events"].gsub!(/example2.com/,InboundEmail::INBOUND_DOMAIN)
      orig_recognition_count = Recognition.count
      orig_email_count = ActionMailer::Base.deliveries.count

      expect {
        post :create, data
      }.to_not raise_error

      expect(Recognition.count).to eq(orig_recognition_count)
      expect(ActionMailer::Base.deliveries.length).to eq(orig_email_count + 2)
    end
  end

  context "when new sender" do
    before do
      @orig_emails = ActionMailer::Base.deliveries.length
      post :create, mandrill_data
    end

    it 'creates new unconfirmed user' do
      user = User.where(email: "example.sender@mandrillapp.com").first
      verify_url = verify_signup_url(user.perishable_token, host: "http://l.recognizeapp.com", port: 50000).gsub(/\/$/, '')

      expect(user).to be_present
      expect(user.from_inbound_email_id).to be_present
      expect(user.status).to eq("pending_signup_completion")
      expect(ActionMailer::Base.deliveries.length).to eq(@orig_emails + 2)
      expect(ActionMailer::Base.deliveries.last).to have_content(verify_url)
    end
  end

  context "when existing sender" do
    before do
      post :create, mandrill_data
    end    

  end
end