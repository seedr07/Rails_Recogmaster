require 'spec_helper'

describe UserSession do
  context "when saving a UserSession" do
    before do
      activate_authlogic
      @user = FactoryGirl.create(:active_user)
      @user_session = UserSession.new(email: @user.email, password: "abcdef")
    end

    it "should save the first login at for the user" do
      @user.first_login_at.should be_blank
      @user_session.save.should be_true
      @user.reload.first_login_at.should be_kind_of(Time)
    end
  end
end
