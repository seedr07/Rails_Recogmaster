class LoggedInConstraint < Struct.new(:which_route)
  def matches?(request)
    request.session["init"] = true # this forces loading
    userid = request.session["user_credentials_id"]
    userexists = User.where(id: userid).exists?
    if which_route == :logged_in_route
      matches = userexists
    else
      matches = !userexists
    end
    return matches
  end
end