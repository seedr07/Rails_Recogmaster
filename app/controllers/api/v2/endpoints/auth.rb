class Api::V2::Endpoints::Auth < Api::V2::Base
  include Api::V2::Defaults

  class Entity < Grape::Entity
    root 'auth', 'auth'
    expose :access_token, documentation: { type: String, description: 'Api Token' }
    expose :token_type, documentation: { type: String, description: 'Type of token granted' }
    expose :scopes, documentation: { type: String, description: 'Grant scopes' }
    expose :user, documentation: { type: User, description: 'Attributes about the current user' }

    def access_token
      token = object.token
    end

    def token_type
      "Bearer"
    end

    def scopes
      object.scopes.to_a
    end

    def user
      user = User.find(object.resource_owner_id) if object && object.resource_owner_id
      Api::V2::Endpoints::Users::Entity.new(user)
    end
  end

  mount Api::V2::Endpoints::Auth::Login
  mount Api::V2::Endpoints::Auth::Ping


end