class Autocompleter
  def initialize(app)
    @app = app
  end

  def call(env)
    # Rails.logger.debug "[Autocompleter] - #{env['PATH_INFO']}" unless env['PATH_INFO'].match(/\/assets/) || env['PATH_INFO'].match(/\/uploads/) 
    if env['PATH_INFO'] == "/coworkers"
      autocomplete(env)
    else
      @app.call(env)
    end
  end

  def not_authorized
    [401, {"Content-Type" => "text/plain"}, "Not Authorized"]
  end

  private
  def autocomplete(env)
    request = Rack::Request.new(env)

    return not_authorized if request.cookies.nil?

    unless Rails.configuration.host == "recognizeapp.com"
      session_key = "#{Recognize::Application.config.session_options[:key]}"
    else
      session_key = "_session_id"
    end

    session = ActiveRecord::SessionStore::Session.find_by_session_id(request.cookies[session_key])
    if session
      user = User.find(session.data['user_credentials_id'])

      term, limit = request.params["term"], request.params["limit"]
      include_self = !!request.params["include_self"]
      Rails.logger.debug "[Autocompleter] - term: #{term}"
      
      list = user.coworkers(term, limit: limit, include_self: include_self)
      list = list[0..limit[1].to_i] if limit && limit[1]
      [200, {"Content-Type" => "text/plain"}, [list.to_json]]
    else
      return not_authorized
    end    
  rescue Exception => e
    Rails.logger.warn "[Autocompleter] failed autocomplete request: #{request.inspect}"
    Rails.logger.debug "[Autocompleter] #{e.message}"
    Rails.logger.debug "[Autocompleter] #{e.backtrace.join("\n")}"
    ExceptionNotifier.notify_exception(e, data: {request: request})              
  end
end