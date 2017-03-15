class UserSessionsController < ApplicationController

  def new
    @user = User.new
    @user_session = UserSession.new
  end

  def create
    if params[:user_session] && params[:user_session][:network]
      @company = Company.find_by(domain: params[:user_session][:network])
      @user_session = @company.user_sessions.build(params[:user_session])
    else
      @user_session = UserSession.new(params[:user_session])
    end

    @user = @user_session.user 
       
    if @user_session.save
      if session[:return_to].present?
        redirect_to session.delete(:return_to)
      else
        if request.xhr?
          respond_with @user_session.user, location: authenticated_root_url(refresh: true)
        else
          redirect_back_or_default authenticated_root_url
        end
      end
    else
      if request.xhr?
        respond_with @user_session
      else
        @user = User.find_by_email(@user_session.email)
        render :action => 'new'
      end
    end
  end

  def destroy
    @user_session = UserSession.find
    @user_session.destroy if @user_session
    session.delete(:user_credentials_id)
    session.delete(:email)
    session.delete(:superuser)
    flash[:notice] = "Successfully logged out."
    redirect_to root_url
  end

  def ping
    if current_user
      response = {status: true}
    else
      response = {status: false}
    end
    render json: response.to_json
  end

end
