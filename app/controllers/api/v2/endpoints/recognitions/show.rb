class Api::V2::Endpoints::Recognitions::Show < Api::V2::Endpoints::Recognitions
  resource :recognitions, desc: '' do

    # GET /recognitions/:id
    desc 'Show info about a recognition, searching by id' do
      detail 'You may only get info about recognitions in your network'
    end
    params do
      requires :id, type: String
    end

    oauth2 'read'

    object { Recognition.find_from_param!(params[:id]) }
    authorize { object.permitted_to?(:destroy, user: current_user) }

    get '/:id' do
      recognition = object
      present recognition
    end    



  end
end
