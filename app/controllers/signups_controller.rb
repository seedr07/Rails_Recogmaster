class SignupsController < ApplicationController
  before_filter :ensure_email_is_provided, except: [:create, :confirm_email, :verify, :welcome, :finish, :requested, :recognize, :personal_interest]
  before_filter :load_user_using_perishable_token, only: :verify
  before_filter :require_user, only: [:welcome, :finish]
  def create
    @user = User.signup!(params[:user])

    #new domain users will be pending signup completion
    #whereas existing domain users will be pending email verification
    if @user.personal_account? or @user.pending_signup_completion?
      respond_with @user, includes: @user.company
    else
      respond_with @user, location: confirm_email_signups_path
    end
  end
  
  def full_name
    @user = User.find_by_email(params[:user][:email])
    @user.first_name = params[:user][:first_name]
    @user.last_name = params[:user][:last_name]
    @user.save
    respond_with @user, includes: @user.company    
  end
  
  def password
    @user = User.find_by_email(params[:user][:email])
    @user.first_name = params[:user][:first_name] if params[:user].has_key?(:first_name)
    @user.last_name = params[:user][:last_name] if params[:user].has_key?(:last_name)
    @user.password = params[:user][:password]
    @user.force_password_validation = true
    @user.save

    if @user.errors.blank?
      InboundEmail.release!(@user)
      @user.set_status!(:active)
      UserSession.create!(@user)
    end

    flash[:newly_signedup] = true
    url = @user.personal_account? ? user_path(@user, refresh: true) : welcome_path(network: @user.network, refresh: true)
    respond_with @user, location: url
  end
    
  def confirm_email
  end
  
  def verify

    @user.verify!
    @user.reset_perishable_token!

    # edge case if you click a verify link
    # and are logged in as someone else
    if current_user and current_user != @user
      # log out current user so that
      # when redirected you can input password
      # for verified user
      logout_current_user
    end
    
    # its possible you can verify your email and still be logged in
    # as in the case of the very first user who has 24h to verify
    if !current_user
      if @user.ok_to_login?
        flash[:newly_signedup] = true
        UserSession.create!(@user)
      else
        session[:email] = @user.email
      end    
    end

    # setup tracking properties
    opts = {roles: @user.roles.map(&:name)}
    opts[:campaign] = params[:campaign] if params[:campaign].present?
    opts[:campaign_group] = params[:campaign_group] if params[:campaign_group].present?
    flash_track_event("Verified Email", opts)

    if params[:campaign_group].present?
      # create a event for the email click through
      flash_track_event("Clicked through #{params[:campaign_group].to_s}", campaign: params[:campaign], page: view_context.page_id)
    end

    if @user.personal_account? and @user.ok_to_login?
      url = user_path(@user)
    elsif @user.company.disable_passwords?
      url = identity_provider_path(@user.network)
    else
      url = sign_up_path
    end
    
    redirect_to url and return
  end
  
  def requested
    @encoded_email = params[:id] #Base64 encoded
  end
  
  def personal_interest
    @sr = SignupRequest.find_by_email(Base64.decode64(params[:email].to_s))
    if params[:interested] == "yes"
      @sr.update_attribute(:pricing, "personal")
    end
    render nothing: true
  end

  def recognize
  end

  protected
  def handle_blacklisted_emails
    if params[:user] and params[:user][:email] and User.blacklisted_email?(params[:user][:email])
      sr = SignupRequest.create(email: params[:user][:email])
      respond_with sr, location: requested_signups_path(id: Base64.encode64(sr.email))
    end
  end
  #TODO: i removed the before_filter that calls this, but perhaps in the future we
  #      will want to use this for the paid model...
  def restrict_to_beta_domains
    if params[:user] and params[:user][:email].present? and User.new(email: params[:user][:email]).valid?
      e = params[:user][:email]
      if !Company.beta_domain?(e.split("@")[1]) and !User.blacklisted_email?(e)
        sr = SignupRequest.find_or_initialize_by(email: e, pricing: params[:pricing])

        if sr.persisted?
          flash[:notice] = "You've already signed up with that email. We'll contact you shortly."
        else
          sr.save!
          SystemNotifier.delay.signup_request(sr)
        end

        respond_with sr, location: requested_signups_path
        return false
      end
    end
  end
  
  def ensure_email_is_provided
    unless params[:user] and params[:user][:email]
      user = User.new
      user.errors.add(:base, "Email is missing, Please return to homepage and enter email address")
      respond_with user, location: root_path
    end
  end

  def load_user_using_perishable_token
    # @user = User.find_using_perishable_token(params[:id])  
    @user = User.where(perishable_token: params[:id]).first
    unless @user
      flash[:notice] = "This link has expired.  Please resubmit the password reset form and we will send you an email to access your account"  
      redirect_to new_password_reset_path  and return false
    end
  end    
end
