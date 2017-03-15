class HomeController < ApplicationController

  attr_accessor :awards, :rewards, :pricing, :privacy_policy, :analytics,
                :terms_of_use, :contest, :gamification, :engagement,
                :customizations, :getting_started, :office365, :mobile

  def index
    @user_session = UserSession.new
    @support_email = SupportEmail.new
    @support_email.type = params[:type]
    
    #session[:email] may be nil(and probably is) and that's ok
    @user = User.find_or_initialize_by(email: session[:email])

    #the session may contain an email of user that is 
    #all setup and ok to login
    if @user.ok_to_login?
      #if so, then clear out of session and present a new user
      session.delete(:email)
      @user = User.new
    end
    
    @user.company = Company.new unless @user.company 
    
    @pageName = "marketing-home"
  end
  
  def distributed_workforce_infographic
  end

  def tour
    @user = User.new(company: Company.new)
  end

  def sign_up
    if @current_user
      redirect_to root_path
    else
      @user = User.find_or_initialize_by(email: session[:email])
      @user.company = Company.new unless @user.company 
    end
  end

  def features
    @user = User.new(company: Company.new)
  end

  def case_study
    @user = User.new(company: Company.new)
  end

  def about
    @user = User.new(company: Company.new)
  end

  def extension
    @user = User.new(company: Company.new)
  end

  def why
    @user = User.new(company: Company.new)
  end

  #a view of the maintenance page for development
  def maintenance
    render action: "maintenance", layout: false
  end

  def upgrade
    if current_user.present?
      opts = {network: current_user.network}
      opts[:code] = params[:code] if params[:code].present?
      redirect_to upgrade_path(opts)
    else
      flash[:notice] = "Please login to upgrade your account"
      store_location
      redirect_to login_path
    end
  end

  def robots
    render action: "robots", layout: false
  end

  def proxy
    render action: "proxy", layout: false
  end

  protected

  def use_marketing_layout?
    true
  end

  def is_home?
    true
  end
end
