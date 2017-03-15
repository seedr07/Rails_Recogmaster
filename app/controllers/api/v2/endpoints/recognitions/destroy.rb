class Api::V2::Endpoints::Recognitions::Destroy < Api::V2::Endpoints::Recognitions
  resource :recognitions, desc: '' do

    # GET /recognitions/:id
    desc 'Destroy a recognition by id' do
      detail 'You may only delete a recognition you have permission to delete'
    end
    params do
      requires :id, type: String
    end

    oauth2 'write'    
    
    object { Recognition.find_from_param!(params[:id]) }
    authorize { object.permitted_to?(:destroy, user: current_user) }

    delete '/:id' do
      recognition = object
      recognition.destroy
      present recognition
    end    



  end
end
