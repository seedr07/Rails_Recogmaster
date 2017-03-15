  class PasswordResetsController < ApplicationController
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]

  def index
    redirect_to new_password_reset_path
  end
  
  def new
  end

  def create
    @user = User.find_by_email(params[:email])
    if @user
      if @user.company.disable_passwords?
        flash[:notice] = "Passwords have been disabled as per your company policy."
        redirect_to identity_provider_path(network: @user.network)

      elsif params[:which_form] && params[:which_form] == "password_reset"
        @user.deliver_password_reset_instructions!  
        flash[:notice] = "Instructions to reset your password have been emailed to you. Please check your email."
        redirect_to login_url
      else
        UserNotifier.verification_email(@user).deliver
        flash[:notice] = "Your verification email has been successfully sent.  Please check your email."
        redirect_back_or_default
      end
    else  
      flash[:notice] = "No user was found with that email address"  
      render action: :new  
    end      
  end

  def edit
  end

  def update
    @user.password = params[:user][:password]  
    @user.skip_original_password_check = true
    @user.force_password_validation = true
    @user.skip_name_validation = true
    
    if @user.save
      #TODO: abstract and move all this to a model...
      
      #the forgot password flow can also serve as email verification for all users except first user
      @user.verify_and_activate!
      
      UserSession.login_as!(@user.reload)
      flash[:notice] = "Password successfully updated"  
      redirect_to root_url  
    else  
      flash[:error] = "There was a problem updating your password"
      render :action => :edit  
    end     
  end


protected

private  
  def load_user_using_perishable_token  
    # @user = User.find_using_perishable_token(params[:id])  
    @user = User.where(perishable_token: params[:id]).first
    unless @user  
      flash[:notice] = "This verification link has expired, please resubmit the password reset form."  
      redirect_to new_password_reset_path  
    end   
  end
end
