require 'spec_helper'

describe CompaniesController do

  before(:each) do
    @user = login(:active_user)
  end  

  describe "GET show" do
    render_views

    it "does allow access to sample company admin if not paid" do
      get :show, {network: @user.network}
      assigns(:company).should eq(current_user.company)
      response.status.should == 200
      response.should render_template :show
      response.should render_template(partial: 'companies/_show_sample')
    end

    it "does allow access to full company admin if paid" do
      Company.any_instance.stub(:allow_admin_dashboard?).and_return(true)
      get :show, {network: @user.network}
      expect(@user.reload.company.allow_admin_dashboard?).to be_true
      assigns(:company).should eq(current_user.company)
      response.status.should == 200
      response.should render_template :show
      response.should render_template(partial: 'companies/_show')
    end

    it "does allows access once paid" do
      @user.company.allow_admin_dashboard = true
      @user.company.save
      get :show, {network: @user.network}
      assigns(:company).should eq(current_user.company)
      response.should be_success
    end

  end

end
