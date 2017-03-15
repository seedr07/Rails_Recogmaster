require 'spec_helper'

describe Comment do
  context "when working with a Comment" do 

    subject { Comment.new }
    
    it { should validate_presence_of :commenter_id }
    it { should validate_presence_of :commentable_id }
    it { should validate_presence_of :commentable_type }
    it { should validate_presence_of :content }
    it { should belong_to :commentable}    
    it { should belong_to :commenter}    
  end

  context "when assigning a comment to a recognition" do
    before do
      @recognition = FactoryGirl.create(:recognition)
      @commenter = @recognition.recipients[0]
    end

    it "should not save comments without required attributes" do
      expect {
        comment = @recognition.comments.build
        comment.save
        }.to_not change{Comment.count}
    end

    it "should not save comments without required attributes" do
      comment = nil
      expect {
        comment = @recognition.comments.build
        comment.content = "that was awesome"
        comment.commenter = @commenter
        comment.save
        }.to change{Comment.count}.by(1)
        @commenter.comments.should == [comment]
    end
  end
end
