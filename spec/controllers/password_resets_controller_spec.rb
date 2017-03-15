require 'spec_helper'

describe PasswordResetsController do

  describe "GET 'new'" do
    it "returns http success" do
      get 'new'
      response.should be_success
    end
  end

  describe "post 'create'" do

    before do
      @user = FactoryGirl.create(:active_user)
      @initial_email_count = ActionMailer::Base.deliveries.count
      post 'create', :email => @user.email, which_form: "password_reset"
    end
    
    it "returns http success" do
      response.should redirect_to login_url
    end
    
    it "sends an email" do
      ActionMailer::Base.deliveries.count.should == @initial_email_count + 1
    end
  end

  describe "GET 'edit'" do
    before do
      @user = FactoryGirl.create(:active_user)
    end
    
    it "returns http success" do
      get 'edit', id: @user.perishable_token
      response.should be_success
    end
  end

  describe "GET 'update'" do
    before do
      @user = FactoryGirl.create(:active_user)
    end
    it "returns http success" do
      put 'update', id: @user.perishable_token, user: {password: "abcdef", password_confirmation: "abcdef"}
      response.should redirect_to root_url
    end
  end

end
