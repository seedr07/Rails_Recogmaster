class Api::V2::Endpoints::Auth::Ping < Api::V2::Endpoints::Auth
  resource :auth, desc: '' do
    desc 'Ping the api to check the status of authentication'

    oauth2
    route_setting(:x_auth_email, optional: true)
    
    get '/ping' do
      current_token.resource_owner_id = current_user.try(:id)
      present current_token
    end    
  end
end
