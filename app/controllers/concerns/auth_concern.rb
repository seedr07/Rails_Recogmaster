module AuthConcern
  def oauth_safe_origin
    if @oauth && @oauth.origin && !["/login", "/user_sessions"].detect{|u| Domainatrix.parse(@oauth.origin).path.match(/#{u}/)}
      @oauth.origin
    end
  end

  def origin_or_root
    oauth_redirect = @oauth ? @oauth.params["redirect"] : nil
    url = oauth_redirect || session[:return_to] || oauth_safe_origin || authenticated_root_path
    session[:return_to] = nil
    return url
  end

  def sign_in_and_redirect(user, url = origin_or_root)
    if !current_user || (current_user != user)
      user_session = UserSession.new(user, true)
      user_session.save!
    end
    if request.xhr?
      render :js => "window.location = '#{url}'"
    else
      redirect_to url
    end
  end  
end