require 'spec_helper'

describe UsersController do
  
  before do
    login
    @user = current_user
  end
  
  def valid_attributes
    FactoryGirl.attributes_for(:user)
  end
    
  context "when updating a profile" do
    before do
    end
    
    it "should update basic attributes" do
      domain = @user.company.domain
      new_attributes = {first_name: "Juan", last_name: "Valdez", email: "a#{Time.now.to_f.to_s}@#{domain}"}
      put :update, {network: domain, id: @user.id, user: new_attributes}
      response.should redirect_to(edit_user_path(@user.reload))
      @user.reload
      @user.first_name.should == new_attributes[:first_name]
      @user.last_name.should == new_attributes[:last_name]
      @user.email.should == new_attributes[:email]
      @user.teams.should be_empty
    end
    
    it "should not allow changing email to a different domain" do
      domain = @user.company.domain
      new_attributes = {email: "#{Time.now.to_f.to_s}@XYZ#{domain}"}
      put :update, {network: domain, id: @user.id, user: new_attributes}
      @user.reload
      response.should render_template("edit")
      assigns(:user).should eq(@user)
    end

    it "should update avatar and hold avatar when updating other parts of profile other than avatar" do
      @user.avatar.default?.should be_true
      domain = @user.company.domain
      image_name = "profile-medium.jpg"
      test_image = File.join(Rails.root, "app/assets/images/users/justin/#{image_name}")
      file = Rack::Test::UploadedFile.new(test_image, "image/jpeg")

      put :update, {network: domain,id: @user.id, user: {avatar: file}}
      response.should redirect_to(edit_user_path(@user.reload))

      @user.reload
      @user.avatar.default?.should be_false
      @user.avatar.file.to_s.match("/uploads/test/avatar_attachment/#{@user.avatar.id}/file/#{image_name}").should be_true

      #ok now test holding of avatar when we just update name
      new_attributes = {first_name: "Juan", last_name: "Valdez"}
      put :update, {network: domain,id: @user.id, user: new_attributes}
      response.should redirect_to(edit_user_path(@user))
      @user.reload
      @user.first_name.should == new_attributes[:first_name]
      @user.last_name.should == new_attributes[:last_name]
      @user.avatar.default?.should be_false
      @user.avatar.file.to_s.match("/uploads/test/avatar_attachment/#{@user.avatar.id}/file/#{image_name}").should be_true
      
    end
    
  end
end
