# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
#  Re: Exception Handling
#
#     Its possible that a user revokes their token via the Yammer app.
#     This leaves you in an inconsistent state having an authentication
#     in the db that has an invalid or expired token.
# 
#     This is easy to deal with if you catch the Unauthorized exception
#     at the controller level.  You just destroy the current users yammer
#     authentication(and token).  
#
#     However, it may be necessary to catch exceptions at the model
#     level so that you can be sure of the return value of a particular
#     method.  But you still need to dsetroy the current users' authentication
#     
#     So the 'hacky' solution I came up with is to pass in 
#     the current_user object during initialization...I don't know if there
#     is a better way...
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
module YammerClient

  def self.included(base)
    base.class_eval do 

      #I need to scope ::YammerClient globally because there
      #seems to be an issue with rails in dev when it reloads things
      def yammer_client
        @client || ::YammerClient::Client.new
      end

      def yammer_client=(new_client)
        @client = new_client
      end
    end
  end
  
  # Convenience accessor to YammerClient::Client.new
  # because YammerClient.new is so much nicer...
  def self.new(*args)
    ::YammerClient::Client.new(*args)
  end
  
  class Client

    # Pass in the user so that we can kill the Yammer authentication
    # during an Unauthorized exception
    def initialize(token=nil, user=nil)
      if Rails.configuration.local_config.has_key?('prevent_yammer_requests')
        @client = MockClient.new
      else
        @client = Yammer::Client.new(access_token: token)
      end
    end
  
    def authenticated?
      @client.access_token.present? 
    end

    def handle_unauthorized(exception, user)
      
      msg = "Caught YammerClient::Unauthorized for user(#{user.log_label}): #{exception.message}"
      msg += "\nThis user may have revoked their Recognize token, so we've deleted their authentication record.  They will need to reauth to use Yammer functionality"
      msg += "\nThis was handled gracefully as long as you don't see this exception for this user again"

      exception.message = msg
      Rails.logger.warn msg
      Rails.logger.warn "Exception: #{exception.backtrace.inspect}"

      ExceptionNotifier.notify_exception(exception, data: {user: "#{user.log_label}", yammertoken: user.yammer_token})
      user.authentications.destroy_all
      raise exception
    end

    def current(opts={})
      return SafeRequest.request!(@client, :current_user)
    end

  private
    # delegate all to Yammer class 
    def method_missing(method, *args, &block)
      Rails.logger.debug " --- CALLING YAMMER CLIENT(#{@user.present? ? @user.log_label : ''})-- #{method} - #{args}"
      4.times do |i|
        Rails.logger.debug " ---  #{caller.grep(/recognize/)[i+2]}"
      end
      Rails.logger.debug "    "

      return SafeRequest.request!(@client, method, *args, &block)

    end  

  end

  class MockClient
    def authenticated?
      return false
    end

    def current
      OpenStruct.new
    end

    def method_missing(method, *args, &block)
      Rails.logger.debug " --- CALLING YAMMER MOCK CLIENT(#{@user.present? ? @user.log_label : ''})-- #{method} - #{args}"
      4.times do |i|
        Rails.logger.debug " ---  #{caller.grep(/recognize/)[i+2]}"
      end
      Rails.logger.debug "    "
      return MockResponse.new
    end

    class MockResponse
      def body
        nil
      end
    end
  end

  class SafeRequest
    attr_reader :client, :method, :args, :block

    def self.request!(client, method, *args, &block)
      new(client, method, *args, &block).send(:request!)
    end

    private

    def initialize(client, method, *args, &block)
      @client = client
      @method = method
      @args = args
      @block = block
    end

    def request!
      safe_request do
        client.send(method, *args, &block)      
      end
    end

    def safe_request
      notify_if_no_access_token!

      attempts = 0
      begin
        response = yield
        return handle_raw_response(response)
      rescue Yammer::Error::Unauthorized => e
        if e.respond_to?(:http_headers)
          # i dont know if this ever hits, this may just be old
          # but leaving just in case
          raise YammerClient::Unauthorized.new(e.message, e.http_headers)
        else
          raise YammerClient::Unauthorized.new(e.message)
        end
      rescue RateLimitExceeded => e
        if attempts < 5
          Rails.logger.info "Rate limit exceeded.  Attempt: #{attempts}, retrying..."
          attempts += 1
          sleep 1
          retry
        else
          Rails.logger.info "Rate limit exceeded.  Attempt: #{attempts}, failing permanently..."
          ExceptionNotifier.notify_exception(e, data: {response: response.inspect, message: "failed even after retrying 5 times"})
          return Hashie::Mash.new
        end
      rescue UserDeactivated
        ExceptionNotifier.notify_exception(e, data: {response: response.inspect})
        return Hashie::Mash.new
      rescue Exception => e
        ExceptionNotifier.notify_exception(e, data: {response: response.inspect})
        raise e        
      end
    end

    def handle_raw_response(response)
      body = response.body
      if body.present?
        case body
        when String
          handle_string_response(body)
        when Array
          body.collect{|item| Hashie::Mash.new(item)}
        when Hash
          Hashie::Mash.new(body) 
        else
          raise "Unkown response type: #{response.inspect}"
        end
      else
        Hashie::Mash.new
      end
    end

    def handle_string_response(response)
      response = parse_and_hash_response(response)
      user = Authentication.where("credentials like '%token: #{client.access_token}%'").where(provider: "yammer").includes(:user).first.user rescue User.new(email: "missing user")
      
      Recognize::Application.yammer_logger.info "----------------------------------------------------------"
      Recognize::Application.yammer_logger.info "  Hit Yammer failed response: #{response.code || 'no code'}"
      Recognize::Application.yammer_logger.info "  User: #{user.email}"
      Recognize::Application.yammer_logger.info "  Request: #{method} - #{args}"
      Recognize::Application.yammer_logger.info "  Response: #{response.to_hash.inspect}"
      Recognize::Application.yammer_logger.info "----------------------------------------------------------"

      case response.code
      when 33, "33" # rate limit exceeded
        Rails.logger.info "Hit Yammer failed response code 33 - rate limit exceeded"
        raise RateLimitExceeded, "Rate limit exceeded; response: #{response.inspect}"
        return nil

      when 34, "34"
        Rails.logger.info "Hit Yammer failed response code 34 - user is inactive"
        return nil

      when 4, "4"
        Rails.logger.info "Hit Yammer failed response code 4 - yammer account deactivated"
        return nil

      when 401, "Authentication failure."
        Rails.logger.info "Hit Yammer failed response code 4 - unauthorized - Authentication failed"
        raise YammerClient::Unauthorized
        return nil

      when 403, "403"
        Rails.logger.info "Hit Yammer failed response code 403 - Request Forbidden - #{response}"
        raise YammerClient::Forbidden
        return nil

      else
        Rails.logger.info "Hit Yammer failed response: #{response.inspect}"
        raise "Yammer request failed with response: #{response.inspect}"
      end
    end

    def parse_and_hash_response(response)
      parsed = JSON.parse(response) 
      parsed["response"] ? Hashie::Mash.new(parsed["response"]) : Hashie::Mash.new(parsed)
    rescue => e
      parsed = Hashie::Mash.new({code: response.code, response: response})
      return parsed
    end

    def notify_if_no_access_token!
      raise MissingAccessToken, "no access token" if client.access_token.blank?
    rescue MissingAccessToken => e
      ExceptionNotifier.notify_exception(e)
    end

  end

  class Unauthorized < Yammer::Error::Unauthorized
    def message=(new_message)
      @message = new_message
    end
    def to_s
      @message.present? ? @message : super
    end
  end

  class RateLimitExceeded < Yammer::Error::RateLimitExceeded
  end

  class UserDeactivated < Yammer::Error::ApiError
  end

  class MissingAccessToken < Yammer::Error::Unauthorized
  end

  class Forbidden < Yammer::Error::Forbidden
  end
end
