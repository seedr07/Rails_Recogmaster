class IdentityProvidersController < ApplicationController
  def show
    @user_session = UserSession.new(email: params[:email])
    @user_session.network = params[:network] # not mass assignable
  end
end