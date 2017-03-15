module UserSessionHelper
  def current_user(stubs = {})
    # @current_user ||= mock_model(User, stubs)
    @current_user #||= FactoryGirl.create(:user)
  end

  def user_session(stubs = {}, user_stubs = {})
    # @current_user_session ||= mock_model(UserSession, {:user => current_user(user_stubs), :record => current_user(user_stubs)}.merge(stubs))
    @current_user_session #||= UserSession.create(current_user)
  end

  def login(user = :active_user)
    # UserSession.stub!(:find).and_return(user_session(session_stubs, user_stubs))
    activate_authlogic unless @current_user && @current_user_session#maybe i've already activated?
    @current_user ||= user.kind_of?(User) ? user : FactoryGirl.create(user)
    @current_user_session ||= UserSession.create(@current_user, true)
    return @current_user
  end

  def login_as(user, pw = "abcd", options={})
    if user.kind_of?(Symbol)
      if options[:coworker]
        u = FactoryGirl.create(user, email: "email#{FactoryGirl.generate(:count)}@"+options[:coworker].company.domain)
      else
        u = FactoryGirl.create(user, options)
      end
    elsif user.kind_of?(User)
      u = user
    else
      raise "unsupported user: #{user}"
    end

    # the new hotness
    begin
      if ENV['DEBUG']
        puts "logging in" if ENV['DEBUG']
        Rails.logger.debug ' --- logging in --- '
      end
      page.set_rack_session("user_credentials" => u.persistence_token, "user_credentials_id" => u.id)
    rescue Capybara::Webkit::InvalidResponseError => e
      print("...session invalid response...") if ENV['DEBUG']
    end
    # unless options[:skip_visit]
    #   visit login_path
    # end
    
    # unless page.has_selector?("#header-login")
    #   visit logout_path
    # end
    
    # click_on "header-login"

    # within("#login-menu") do
    #   fill_in 'Email', :with => u.email
    #   fill_in 'Password', :with => pw

    #   find("input[type=submit]").click
    #   if options[:skip_visit]
    #     wait_until_ajax_completes
    #   else
    #     wait_until_page_is_redirected_from("/login")
    #   end
    # end
    return u
  end
    
  def logout
    @current_user_session = nil
  end
end