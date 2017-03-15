module ApiHelper

  class Forbidden < Seahorse::Exception
    status 403
    name "Forbidden"
  end

  class ArgumentError < Seahorse::Exception
    status 400
    name "ArgumentError"
  end

  class RecordInvalid < Seahorse::Exception
    status 406
    name "RecordInvalid"
  end
  
  def log_requester
    Rails.logger.info "Api::V1::BaseController Request: #{session["user_credentials_id"]}:#{session["user_credentials"]}"
  end

  def track_request
    if current_user.present?
      ::Analytics.track(
        user_id: current_user.id, 
        event: "API: /#{controller_name}/#{action_name}", 
        properties: {
          api: true,
          controller: controller_name, 
          email: current_user.email, 
          network: current_user.network,
          admin_dashboard_enabled: current_user.company.allow_admin_dashboard,
          custom_badges: current_user.company.custom_badges_enabled?,
          has_subscription: current_user.company.subscription.present?,
          using_oauth: using_oauth?,
          user_agent: env["HTTP_USER_AGENT"]
        })
    end
  rescue => e
      ExceptionNotifier.notify_exception(
        Exception.new("Failed tracking api request: #{controller_name}##{action_name}"), 
        data: {current_user: current_user.id, network: current_user.network})  
  end  

  private
  def using_oauth?
    http_auth = env["HTTP_AUTHORIZATION"] and http_auth.match(/Bearer/)
  end
end