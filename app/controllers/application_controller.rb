class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user
  before_filter :set_exception_data
  before_filter :set_locale
  before_filter :set_company
  before_filter :ensure_correct_company, except: [:routing_error]
  before_filter :load_yammer_client
  before_filter :set_superuser
  before_filter :set_send_recognition_form

  before_filter :set_chat_thread

  #tell DeclarativeAuthorization which user to evaluate for permissioning
  before_filter { |c| Authorization.current_user = c.current_user }
  before_filter :miniprofiler
  after_action :allow_iframe
  after_action :track_request

  include UserSessionsHelper
  include ApiHelper
  include ExceptionHelper
  include ActionView::RecordIdentifier

  filter_access_to :all

  self.responder = ApplicationResponder
  respond_to :html, :js, :json

  rescue_from YammerClient::Unauthorized, with: :handle_oauth_error

  def set_chat_thread
    if current_user.blank?
      @chat_thread = ChatThread.new
    end
  end

  def set_send_recognition_form
    if current_user.present?
      @send_recognition = current_user.recognitions.new
      @jsClass = "Recognition"
      @send_recipient = recipient_from_params
    end
  end

  def set_locale
    I18n.locale = (locale_from_params || (current_user && current_user.locale) || I18n.default_locale)
  end

  def locale_from_params
    if params[:locale].present?
      if params[:locale].scan(/locale/).length >= 1
        params[:locale].gsub('?locale=en-GB','')
      else
        params[:locale].gsub(/\?.*/,'')
      end
    end
  end

  def default_url_options(options={})
    if I18n.locale == I18n.default_locale
      {}
    else
      { locale: I18n.locale }
    end
  end

  def routing_error
    if current_user and (params[:network] != current_user.network and params[:network] != "uploads")
      Rails.logger.info "AppController#routing_error - first conditional"
      # if params[:network] is an actual domain, swap it out
      # otherwise, add the correct network in(useful for getting to proper routes without knowledge of which network is correct)
      # eg from sharepoint
      if Company.exists?(domain: params[:network])
        u = request.fullpath.gsub(params[:network], current_user.network)
      else
        u = "/#{current_user.network}#{request.fullpath}"
      end
      redirect_to u
    # NOTE: 11/2/2015 - the original intention here was to be able to have routes that could be specified without a network
    #       if the user is logged in, they'll be redirected appropriately
    #       if the user is not logged in, they'll be redirected to sign in page and then redirected to correct page
    #       However, this was problematic with routes like /rewards which has both a marketing page and a logged in
    #       page.
    #       So instead, I'm switching to a model where you can specify /redirect/:path,
    #       and then the behavior above will kick in.
    elsif request.path.match(/\/redirect/) && valid_route_but_without_network?
      Rails.logger.info "AppController#routing error - redirect to valid route without network: #{recognize_signups_path}"
      # we're trying to go to a valid route but we haven't specified a network, and we're not logged in
      # so sign up/in page with ability to redirect to original route
      store_location
      if sharepoint_viewer?
        redirect_to office365_path
      else
        redirect_to recognize_signups_path
      end
    elsif path = valid_route_without_redirect_keyword?
      Rails.logger.info "AppController#routing error - redirect to valid route without redirect keywork:#{path}"
      redirect_to path
    else
      render file: "public/404", :status => 404
    end
  end

  def permission_denied
    if current_user
      msg = "Sorry. You do not have permission to access that page. "+view_context.link_to("Go back to where you came from", :back)
      render text: msg, layout: true, status: 401
    else
      flash[:error] = "You must login to access that page"
      #use helpers/user_sessions_helper
      #so we can store location and redirect back upon login
      require_user
    end
    return false
  end


  def url_options
    super().merge(params.slice("viewer", "referrer").symbolize_keys)
  end

  private

  def sharepoint_viewer?
    params[:viewer] == "sharepoint"
  end
  helper_method :sharepoint_viewer?

  # See note above in routing error.
  def valid_route_but_without_network?
    path = request.path.gsub(/^\/redirect/, '/recognizeapp.com')
    route_params = Rails.application.routes.recognize_path(path)
    return route_params[:action] != "routing_error"
  end

  def valid_route_without_redirect_keyword?
    path = request.fullpath.gsub(/redirect\//,'')
    if Rails.application.routes.recognize_path(path)[:action] != "routing_error"
      return path
    else
      return false
    end
  end

  def recipient_from_params
    if params[:recipient].kind_of?(Hash) && params[:recipient][:email].present?
      recipient = User.where(email: params[:recipient][:email]).first_or_initialize
      recipient.assign_attributes(params[:recipient])
    elsif params[:recipient] && params[:recipient_network]
      recipient = User.where(slug: params[:recipient], network: params[:recipient_network]).first
    else
      recipient = nil
    end

    recipient.yammer_id = params[:recipient_yammer_id] if params[:recipient_yammer_id].present?

    return recipient
  end

  def sendable_nomination_badges
    @badges ||= current_user.sendable_nomination_badges
  end

  def sendable_recognition_badges
    @badges ||= current_user.sendable_recognition_badges
  end
  helper_method :sendable_nomination_badges, :sendable_recognition_badges

  def set_company

    @company = if current_user
      current_user.director? && params[:network].present? ?
        current_user.company.family.detect{|c| c.domain == params[:network]} :
        current_user.company
    else
      Company.where(domain: params[:network]).first if params[:network].present?
    end

  end

  def scoped_company
    @company ||= set_company
  end

  def load_yammer_client(user = current_user)
    token = user ? user.yammer_token : nil
    Recognize::Application.yammer_client = YammerClient::Client.new(token, current_user)
  end

  def handle_oauth_error(exception)
    Rails.logger.warn "Handling OAUTH error for user: #{current_user.try(:id) || 'no user'}"
    # Recognize::Application.yammer_client.handle_unauthorized(exception, current_user)
    flash.now[:error] = "There was an error with your Yammer Authentication.  If this is an error, please reauthenticate."
    # render action: params[:action]
    url = "/auth/yammer"
    if request.xhr?
      render js: "sweetAlert({showCancelButton:true,cancelButtonText:'Not now',confirmButtonText: 'Authenticate',title:'Your yammer authentication has expired',text: 'Please reauthenticate for full Yammer functionality'}, function(){window.location='#{url}'})", status: 401
    else
      redirect_to url
    end
  end

  def miniprofiler
    if params[:debug] and defined?(Rack::MiniProfiler)
      Rack::MiniProfiler.authorize_request
    end
  end

  # track events after redirect
  def flash_track_event(event, props)
    flash[:trackEvents] ||= []
    flash[:trackEvents] << {event: event, properties: props}
  end

  def flash_add_prop_to_page_event(props)
    flash[:trackProperty] = props
  end

  def set_superuser
    if current_user and session.has_key?(:superuser)
      current_user.acting_as_superuser = session[:superuser]
    end
  end

  def ensure_correct_company
    if current_user and params[:network].present? and !current_user.admin? and current_user.network != params[:network]
      if !current_user.director? || !current_user.company.family.map(&:domain).include?(params[:network])
        redirect_to request.fullpath.gsub(params[:network], current_user.network)
        return false
      end
    end
  end

  def allow_iframe
    if params[:viewer] == "sharepoint"
      Rails.logger.info "AppController#allow_iframe: referer: #{request.referer}"
      return if params[:referrer].blank?

      uri = URI.parse(params[:referrer])

      if uri.host.match(/\.sharepoint.com$/)
        url = "https://#{uri.host}"
        Rails.logger.info "AppController#allow_iframe: ALLOW-FROM #{url}"
        response.headers.except! 'X-Frame-Options'
        #response.headers['X-Frame-Options'] = "ALLOW-FROM #{url}"
      end
    else
      response.headers['X-Frame-Options'] = 'ALLOW-FROM https://www.yammer.com'
    end
  end

  def render_people_picker(people, form_object, url)
    render partial: "people/picker", locals: {people: @team.company.users, form_object: form_object, url: url}
  end

  def use_marketing_layout?
    current_user.blank? ? true : false
  end
  helper_method :use_marketing_layout?

  def is_home?
    false
  end
  helper_method :is_home?

  def track_request
    if current_user.present?
      ::Analytics.track(
        user_id: current_user.id,
        event: "PAGE: /#{controller_name}/#{action_name}",
        properties: {
          controller: controller_name,
          email: current_user.email,
          network: current_user.network,
          admin_dashboard_enabled: current_user.company.allow_admin_dashboard,
          yammer: current_user.auth_with_yammer?,
          custom_badges: current_user.company.custom_badges_enabled?,
          has_subscription: current_user.company.subscription.present?,
          using_oauth: using_oauth?,
          user_agent: env["HTTP_USER_AGENT"]
        })
    end
  end

  def self.show_upgrade_banner(opts = {})
    raise "You cannot specify if conditional, it will be overriden" if opts.has_key?(:if)
    before_action -> { @show_upgrade_banner = true }, opts.merge(if: ->{current_user && !current_user.subscribed_account?})
  end

end
