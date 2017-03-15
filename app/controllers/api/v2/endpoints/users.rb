class Api::V2::Endpoints::Users < Api::V2::Base
  include Api::V2::Defaults

  class Entity < Api::V2::Entities::Base
    root 'users', 'user'
    expose :first_name, documentation: { type: String, description: 'First name'}
    expose :last_name, documentation: { type: String, description: 'Last name'}
    expose :email, documentation: { type: String, description: 'Email address'}
    expose :label, documentation: { type: String, description: 'Label to use for user. Will show name, if not email'}
    expose :avatar_thumb_url, as: :avatar_url, documentation: { type: String, description: 'Avatar url'}, if: lambda{|user, options|  user.id.present?}
    expose :network, documentation: { type: String, description: 'Network this user belongs to'}

  end

  # mount Api::V2::Endpoints::Users::Index
  mount Api::V2::Endpoints::Users::Create
  mount Api::V2::Endpoints::Users::Search
  mount Api::V2::Endpoints::Users::Show

end