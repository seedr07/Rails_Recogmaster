YammerClient #hack to make sure constant is loaded in dev env
class Api::V1::BaseController < ActionController::API

  include ActionController::MimeResponds
  include ActionController::StrongParameters
  include ActionController::Cookies
  include ApiHelper
  include ExceptionHelper
  # include AbstractController::Translation

  before_filter :track_request
  before_filter :log_requester
  before_filter :set_exception_data
  around_filter :wrap_exceptions
  after_filter :set_headers
  
  def current_user
    defined?(@current_user) ? @current_user : lookup_user
  end

  private
  def set_headers
    response.headers['Access-Control-Allow-Origin'] = 'https://www.yammer.com'
  end

  def lookup_user
    @current_user = doorkeeper_token.present? \
      ? user_from_doorkeeper_token \
      : user_from_cookie
  end
  
  def user_from_doorkeeper_token
    User.find(doorkeeper_token.resource_owner_id)    
  end

  def user_from_cookie
    # FIXME: probably best not to access cookies directly
    # persistence_token, user_id = cookies["user_credentials"].try(:split, "::")
    # user = User.where(persistence_token: persistence_token, id: user_id).first
    # user
    unless Rails.configuration.host == "recognizeapp.com"
      session_key = "#{Recognize::Application.config.session_options[:key]}"
    else
      session_key = "_session_id"
    end
    session = ActiveRecord::SessionStore::Session.where(session_id: cookies[session_key]).last
    user = User.where(id: session.data["user_credentials_id"]).first if session
    return user
  end

  def wrap_exceptions
    begin
      yield
    rescue ::ArgumentError => e
      raise ApiHelper::ArgumentError.new(e.message)
    rescue ::ActiveRecord::RecordInvalid  => e
      raise ApiHelper::RecordInvalid.new(e.message)
    rescue ::Exception => e
      # only log error if its not an application level exception that sends back a status code
      unless e.respond_to?(:status) && e.status.present?
        user = current_user ? "User:#{current_user.id}:#{current_user.email}" : "no user"
        ExceptionNotifier.notify_exception(e, {data: {user: user}})
      end

      raise e

    end
  end
end