class Api::V2::Endpoints::Auth::Login < Api::V2::Endpoints::Auth
  resource :auth, desc: '' do
    desc 'Authenticate and retrieve an access token' do
      # success Entity
    end

    params do
      requires :client_id, type: String
      requires :email, type: String
      requires :password, type: String
      optional :device_token, type: String
      optional :device_platform, type: String
    end

    route_setting(:x_auth_email, required: false)
    
    post '/' do
      self.request.singleton_class.send(:define_method, :authorization, Proc.new{})
      self.request.singleton_class.send(:define_method, :parameters, Proc.new{return params})
      self.singleton_class.send(:define_method, :resource_owner_from_credentials, Doorkeeper.configuration.resource_owner_from_credentials)

      server = Doorkeeper::Server.new(self)
      strategy = server.token_request "password"
      response = strategy.authorize

      token = response.kind_of?(Doorkeeper::OAuth::TokenResponse) ? response.token : response

      if(params[:device_token].present?)
        DeviceToken.find_or_create_by(user_id: token.resource_owner_id, token: params[:device_token], platform: params[:device_platform])
      end

      present token
    end    
  end
end
