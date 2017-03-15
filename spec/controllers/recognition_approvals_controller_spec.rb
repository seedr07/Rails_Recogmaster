require 'spec_helper'

describe RecognitionApprovalsController do
  before(:each) do
    @user = login(:active_user)
  end
    
  context "when creating new approvals" do
    before do
      @sender = FactoryGirl.create(:active_user, email: "a#{FactoryGirl.generate(:count)}@#{@user.company.domain}")
      @recipient = FactoryGirl.create(:active_user, email: "a#{FactoryGirl.generate(:count)}@#{@user.company.domain}")
      @recognition = FactoryGirl.create(:recognition, sender: @sender, recipients: [@recipient])

    end
    
    it "should successfully create an approval" do
      expect {
        post :create, {network: @user.network, recognition_id: @recognition.to_param, format: :js}
      }.to change(RecognitionApproval, :count).by(1)      
    end
  end
end