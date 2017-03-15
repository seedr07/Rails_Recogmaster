require 'spec_helper'
require 'carrierwave/test/matchers'

describe AttachmentUploader do
  include CarrierWave::Test::Matchers

  before do
    save_provider
    AttachmentUploader.enable_processing = true
    AttachmentUploader.storage :file
    @user = FactoryGirl.create(:user)
    @uploader = AttachmentUploader.new(@user, :attachment)
    @uploader.store!(File.open(File.join(Rails.root, 'public', 'favicon.ico')))
  end
  
  after do
    AttachmentUploader.enable_processing = false
    @uploader.remove!
    AttachmentUploader.storage :fog
    restore_provider
  end
  
  # context 'the thumb version' do
  #   it "should scale down a landscape image to be exactly 64 by 64 pixels" do
  #     @uploader.thumb.should have_dimensions(64, 64)
  #   end
  # end
  # 
  # context 'the small version' do
  #   it "should scale down a landscape image to fit within 200 by 200 pixels" do
  #     @uploader.small.should be_no_larger_than(200, 200)
  #   end
  # end
  
  it "should make the image readable only to the owner and not executable" do
    @uploader.should have_permissions(0744)
  end
end

describe AvatarAttachmentUploader do
  include CarrierWave::Test::Matchers

  before do
    save_provider
    AttachmentUploader.storage :file    
    AvatarAttachmentUploader.enable_processing = true
    @user = FactoryGirl.create(:user)
    @uploader = AvatarAttachmentUploader.new(@user, :attachment)
    @uploader.store!(File.open(File.join(Rails.root, 'public', 'favicon.ico')))
  end
  
  after do
    AvatarAttachmentUploader.enable_processing = false
    @uploader.remove!
    AttachmentUploader.storage :fog
    restore_provider
  end
  
  context 'the thumb version' do
    it "should scale down a landscape image to be exactly 50 by 50 pixels" do
      @uploader.thumb.should have_dimensions(100, 100)
    end
  end
  # 
  # context 'the small version' do
  #   it "should scale down a landscape image to fit within 200 by 200 pixels" do
  #     @uploader.small.should be_no_larger_than(200, 200)
  #   end
  # end
  
  it "should make the image readable only to the owner and not executable" do
    @uploader.should have_permissions(0744)
  end
end

def save_provider
  @old_provider = AttachmentUploader.storage
end

def restore_provider
  AttachmentUploader.storage = @old_provider
end