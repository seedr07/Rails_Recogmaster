class AuthenticationsController < ApplicationController
  include AuthConcern

  before_filter :load_oauth, except: [:failure]
  def index
    @authentications = current_user.authentications if current_user
  end
  
  def create
    @authentication = Authentication.where(provider: @oauth.provider, uid: @oauth.uid).first

    if @authentication.present?
      handle_existing_authentication
    elsif current_user
      handle_existing_user      
    else
      handle_new_user
    end
  end
  
  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    flash[:notice] = "Successfully destroyed authentication."
    redirect_to authentications_url
  end

  def oauth_failure
    p = Rails.application.routes.recognize_path request.path
    if params[:error] == "access_denied"
      flash[:error] = "You have denied access to Recognize from Yammer.  Please create an account or try to login again."
    end

    Rails.logger.warn "--- OAUTH Failure ---"
    Rails.logger.warn env.keys.grep(/omniauth/).map{|k|  "#{k} - #{env[k]}" }.join("\n")
    Rails.logger.warn "--- OAUTH Failure(end) ---"

    redirect_to auth_failure_path(strategy: env['omniauth.error.strategy'].name) and return
  end

  def failure
  end
  
  private

  def handle_existing_authentication
    
    #update token if necessary
    @authentication.update_attribute(:credentials, @oauth.credentials) unless @authentication.credentials.present? and @authentication.credentials.token == @oauth.credentials.token

    refresh_caches!(@authentication.user)

    flash[:notice] = "Signed in successfully."
    sign_in_and_redirect(@authentication.user)    
  end

  def handle_existing_user
    if @oauth.yammer? && @oauth.uid.to_s != current_user.yammer_id.to_s
      user = User.where(yammer_id: @oauth.uid).first
      return handle_new_user unless user
    else
      user = current_user
    end

    # protect against being logged in under one network, and oauth'ing for a user that doesn't have that domain in their networks
     if !@oauth.yammer? || (@oauth.oauth.extra.raw_info.network_domains.kind_of?(Array) && @oauth.oauth.extra.raw_info.network_domains.include?(user.network))
      user.authentications.create!(:provider => @oauth.provider, :uid => @oauth.uid, :credentials => @oauth.credentials)

      # Applying oauth data can be tricky with existing users so, 
      # for now, just allow syncing of google contacts with existing users
      user.sync_google_contacts if @oauth.google?
      user.save!
      refresh_caches!(user)

      flash[:notice] = "Authentication successful."
    else
        ExceptionNotifier.notify_exception(
          Exception.new("Yammer user does not belong to the currently logged in domain - Don't worry this was handled gracefully."), 
          data: {current_user: user.id, network: user.network, yammer_domains: @oauth.oauth.extra.raw_info.network_domains.inspect})  
        flash[:notice] = "We could not sign you in.  Your current yammer credentials do not belong to the current domain"

    end

    if user != current_user
      sign_in_and_redirect(user)
    else
      redirect_to origin_or_root    
    end
  end

  def handle_new_user
    user = User.find_or_create_by_oauth(@oauth)
    if user.save
      user.sync_google_contacts 
      user.verify_and_activate!
      load_yammer_client(user)
      
      refresh_caches!(user)

      flash[:notice] = "Signed in successfully."
      sign_in_and_redirect(user, welcome_path(network: user.network, refresh: true))
    else
      Rails.logger.warn "OAUTH: User authentication failed"
      if user.errors.count > 0
        Rails.logger.warn "OAUTH: errors: #{user.errors.full_messages.join(',')}"
        flash[:notice] = "There was a problem signing you in.  Please try again."
      else
        Rails.logger.warn "OAUTH: failed but user has no errors"
        flash[:notice] = "We could not sign you in with those credentials.  Please try again."
        session[:omniauth] = @oauth.except('extra')
      end
      redirect_to root_path
    end    
  end

  def refresh_caches!(user)
    user.company.delay(queue: 'caching').prime_caches!
    user.delay(queue: 'caching').prime_caches!
  end
  
  def load_oauth
    @oauth = OauthService.new(request.env)
  end
  
  def user_matches_oauth?
    if @oauth.yammer?
      return @oauth.uid == current_user.yammer_id
    end
    return true
  end
end