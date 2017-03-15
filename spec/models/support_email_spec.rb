require 'spec_helper'

describe SupportEmail do
  before do
    @support_email = FactoryGirl.build(:support_email)
  end
  
  it "should have errors when missing required fields" do
    email = SupportEmail.new(type: "support")
    email.save
    email.errors[:name].should be_present
    email.errors[:email].should be_present
    email.errors[:message].should be_present
  end
  
  it "should send email after save" do
    expect{
      @support_email.save
      @support_email.persisted?.should be_true
    }.to change(ActionMailer::Base.deliveries, :count).by(1)
  end
end
