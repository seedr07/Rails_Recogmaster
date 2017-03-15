require 'spec_helper'

describe AvatarAttachment do
  context "when working with a basic instance" do
    subject { Attachment.new }

    it { should belong_to :owner }
  end

  context "when saving a valid instance" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:attachment)
      @attachment = AvatarAttachment.new(@attrs)
      @attachment.save
    end
    
    it "should be persisted" do
      @attachment.persisted?.should be_true
    end
    
    it "should have all attributes set" do
      @attachment.reload
      @attrs.each do |attr, val|
        if attr == :file
          filename = File.basename(val)
          @attachment.file.filename.should == filename
        else
          @attachment.send(attr).should == val
        end
      end
    end
  end
  
  context "when working with avatar attachment subclass" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:avatar_attachment)
      @attachment = AvatarAttachment.new(@attrs)
      @attachment.save
    end
    
    it "should be persisted" do
      @attachment.persisted?.should be_true
    end
    
    it "should have all attributes set" do
      @attachment.reload
      @attrs.each do |attr, val|
        if attr == :file
          filename = File.basename(val)
          @attachment.file.filename.should == filename
        else
          @attachment.send(attr).should == val
        end
      end
    end
  end
end