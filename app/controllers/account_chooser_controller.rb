class AccountChooserController < ApplicationController
  def show
    @accounts = User.where(email: params[:email])
    @user_session = UserSession.new(email: params[:email])
  end

  def update
    @user = User.find_by(email: params[:email], network: params[:network])
  end
end