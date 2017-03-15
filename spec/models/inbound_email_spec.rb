require 'spec_helper'

describe InboundEmail do
  let(:email_data) { JSON.parse(MandrillInboundData.data["mandrill_events"])[0]}
  let(:outlook_email_data) { JSON.parse(MandrillInboundData.data_from_outlook["mandrill_events"])[0]}

  context "when creating" do

    it "should create inbound email from data spec" do
      ie = InboundEmail.new(data: email_data)
      expect(ie.save).to be_true
      expect(ie.status).to be InboundEmail::UNPROCESSED
      expect(ie.sender.email).to eq("example.sender@mandrillapp.com")
      expect(ie.recipient_emails).to be_present
    end
  end

  context "when creating from outlook email with signature" do
    it "should create truncated inbound email from data spec" do
      ie = InboundEmail.new(data: outlook_email_data)
      expect(ie.save).to be_true
      expect(ie.status).to be InboundEmail::UNPROCESSED
      expect(ie.sender.email).to eq("example.sender@mandrillapp.com")
      expect(ie.recipient_emails).to be_present
    end
  end

  context "when releasing" do
    let!(:inbound_email) { InboundEmail.create(data: email_data) }

    it "should create a recognition" do
      expect{
        inbound_email.release!
      }.to change{Recognition.count}.by(1)

      recognition = Recognition.first
      expect(recognition.recipients.first.email).to eq("rcp1@example1.com")
      expect(recognition.message).to eq("This is an example webhook message: This is an example inbound message.\n")
    end

    it 'sends confirmation email' do
      expect{
        inbound_email.release!
      }.to change{ActionMailer::Base.deliveries.count}.by(2) # recognition email and confirmation email

      last_email = ActionMailer::Base.deliveries.last
      expect(last_email.subject).to match("has been delivered")
      expect(last_email.body).to match("has been sent")
    end

    it 'can not release an inbound email more than once' do
      expect{
        inbound_email.release!
        inbound_email.release!
      }.to change{Recognition.count}.by(1)
    end
  end
end