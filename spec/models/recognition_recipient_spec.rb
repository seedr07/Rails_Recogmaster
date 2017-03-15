require 'spec_helper'

describe Recognition do
  context "when working with a recognition recipient" do
    subject { RecognitionRecipient.new }
    
    it { should belong_to :recognition }
    it { should belong_to :user }
  end

  context "when creating a new recognition recipient" do
    before do
      @recognition_recipient = FactoryGirl.create(:recognition_recipient)
      @recognition_recipient.reload
    end

    it "should have association to recognition" do
      @recognition_recipient.recognition.should be_kind_of(Recognition)
      @recognition_recipient.recognition.recipients.should be_kind_of(Array)
      @recognition_recipient.recognition.recognition_recipients.should include(@recognition_recipient)
      @recognition_recipient.recognition.recipients.should include(@recognition_recipient.user)
    end

    it "should have association to recipient" do
      @recognition_recipient.user.should be_kind_of(User)
      @recognition_recipient.user.recognition_recipients.should be_kind_of(ActiveRecord::Associations::CollectionProxy)
      @recognition_recipient.user.recognition_recipients.should include(@recognition_recipient)
      @recognition_recipient.user.received_recognitions.should include(@recognition_recipient.recognition)
    end
  end

  context "when testing recognizing multiple user recipients" do
    before do
      @count = 3
      @user = FactoryGirl.create(:active_user)
      @recipients = (1..@count).collect{ FactoryGirl.create(:active_user)}
      @badge = Badge.user_badges.last
    end

    it "should save the recognition" do
      expect {
        recognition = @user.recognize!(@recipients, @badge, "great job")
        recognition.should be_persisted
        recognition.recipients.should == @recipients
      }.to change{Recognition.count}.by(1)
    end
  end
end