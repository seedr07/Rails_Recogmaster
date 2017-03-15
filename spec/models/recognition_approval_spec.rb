require 'spec_helper'

describe RecognitionApproval do
  def valid_attrs
    FactoryGirl.attributes_for(:recognition_approval)
  end

  context "when working with associations for a RecognitionApproval" do 

    subject { RecognitionApproval.new }
    
    it { should validate_presence_of :giver_id }
    it { should validate_presence_of :recognition_id }
    it { should belong_to :giver }
    it { should belong_to :recognition }
  end  
  
  context "when working with validations for a RecognitionApproval" do
    before do
      @recognition = FactoryGirl.create(:recognition)
      @domain = @recognition.sender.company.domain
      @user = FactoryGirl.create(:user, email: "email#{FactoryGirl.generate(:count)}@#{@domain}")
    end

    it "should save when provided a valid recognition and a user in the same company" do
      approval = RecognitionApproval.create(recognition: @recognition, giver: @user)
      approval.persisted?.should be_true
    end
    
    it "should allow a person to plus one a recognition if they are in a different company" do
      user = FactoryGirl.create(:user)
      approval = RecognitionApproval.create(recognition: @recognition, giver: user)
      approval.persisted?.should be_true
      approval.errors.count.should == 0
      approval.errors[:base].should_not be_present
    end
    
    it "should not allow a person to approve their own recognition(given or received)" do
      approval = RecognitionApproval.create(recognition: @recognition, giver: @recognition.sender)
      approval.persisted?.should be_false
      approval.errors.count.should == 1
      approval.errors[:base].should be_present

      approval = RecognitionApproval.create(recognition: @recognition, giver: @recognition.recipients[0])
      approval.persisted?.should be_false
      approval.errors.count.should == 1
      approval.errors[:base].should be_present

    end
    
    it "should not allow a person to approve a recognition more than once" do
      approval = RecognitionApproval.create(recognition: @recognition, giver: @user)
      approval.persisted?.should be_true

      approval = RecognitionApproval.create(recognition: @recognition, giver: @user)
      approval.persisted?.should be_false
      
      
    end
  end
  
  context "when destroying a recognition approval" do
    before do
      @recognition = FactoryGirl.create(:recognition)
      @domain = @recognition.sender.company.domain
      @user = FactoryGirl.create(:user, email: "email#{FactoryGirl.generate(:count)}@#{@domain}")
      @approval = RecognitionApproval.create(recognition: @recognition, giver: @user)
      @approval.destroy
    end
    
    it "should no longer be visible from normal queries" do
      RecognitionApproval.exists?(id: @approval.id).should be_false
    end
    
    it "should be findable if need be" do
      RecognitionApproval.with_deleted.exists?(@approval.id).should be_true
    end
    
    it "should set deleted at field" do
      @approval.deleted_at.should_not be_nil
    end
  end
end
