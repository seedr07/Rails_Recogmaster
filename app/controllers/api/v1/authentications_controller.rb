class Api::V1::AuthenticationsController < Api::V1::BaseController
  include Seahorse::Controller
   
  # For now, ping will be used only in chrome extension,  
  def ping
    if user_matches_authentication?
      response = authenticated_user_response
    else
      response = unauthenticated_user_response
    end
    respond_with response
  end

  # to be used for non-yammer auth checks
  def auth_status
    if current_user
      response = OpenStruct.new(status: !!current_user, user_id: current_user.id)
    else
      response = OpenStruct.new(status: false, user_id: nil)
    end
    respond_with response
  end

  private
  
  def user_matches_authentication?
    if current_user && current_user.auth_with_yammer?
      current_yammer_user = current_user.yammer_client.current
      if params[:username] == current_yammer_user.name || params[:username] == current_yammer_user.id.to_s
        return true
      end
    end
    return false
  rescue YammerClient::Unauthorized => e
    return false
  end

  def authenticated_user_response
    OpenStruct.new(
      status: !!current_user,
      yammer: !!current_user.try(:yammer_token),
      yammer_id: current_user.try(:yammer_id),
      company_admin: current_user.company_admin?,
      time: Time.now.to_f.to_s,
      network: current_user.try(:network)
    )
  end

  def unauthenticated_user_response
    OpenStruct.new(status: false, yammer: false, yammer_id: nil, time: Time.now.to_f.to_s, company_admin: false, network: false)
  end
end
