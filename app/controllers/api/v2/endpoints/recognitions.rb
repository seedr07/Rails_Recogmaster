class Api::V2::Endpoints::Recognitions < Api::V2::Base
  include Api::V2::Defaults

  class Entity < Api::V2::Entities::Base
    root 'recognitions', 'recognition'
    # expose :slug, documentation: { type: 'string', desc: 'Unique slug'}
    expose :sender, using: Api::V2::Endpoints::Users::Entity, documentation: { type: Api::V2::Endpoints::Users::Entity, desc: 'Sender of the recognition'}
    expose :message, documentation: { type: 'string', desc: 'Recognition message', required: true}
    expose :user_recipients, using: Api::V2::Endpoints::Users::Entity, documentation: { type: Api::V2::Endpoints::Users::Entity, desc: 'User recipients of the recognition. If a team was recognized, each user is listed individually.'}
    expose :badge, using: Api::V2::Endpoints::Badges::Entity, documentation: { type: Api::V2::Endpoints::Badges::Entity, desc: 'Selected badge of the recognition'}
    expose :created_at, as: :sent_at, documentation: { type: 'string', desc: 'Datetime the recognition was sent', required: true}
    expose :permissions
    expose :is_public
  
    def permissions
      edit = object.permitted_to?(:edit, user: current_user)
      delete = object.permitted_to?(:destroy, user: current_user)
      {edit: edit, delete: delete}
    end

  end

  mount Api::V2::Endpoints::Recognitions::Index
  mount Api::V2::Endpoints::Recognitions::Create
  mount Api::V2::Endpoints::Recognitions::Show
  mount Api::V2::Endpoints::Recognitions::Destroy

end