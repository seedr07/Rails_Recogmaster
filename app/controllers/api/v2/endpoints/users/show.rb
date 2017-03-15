class Api::V2::Endpoints::Users::Show < Api::V2::Endpoints::Users
  resource :users, desc: '' do
    # GET /users/show
    desc 'Show info about a user, searching by id or email' do
      detail 'You may only get info about users in your network'
    end
    params do
      optional :id, type: String
      optional :email, type: String
      exactly_one_of :id, :email
    end

    oauth2 'read'
    get '/show' do
      user = User.where("id = :id OR email = :email", id: unhash(params[:id]), email: params[:email]).first
      raise ActiveRecord::RecordNotFound, "Could not find user" unless user
      present user
    end    


    # GET /users/:id
    desc 'Show info about a user, searching by id' do
      detail 'You may only get info about users in your network'
    end
    params do
      requires :id, type: String
    end

    oauth2 'read'
    get '/:id' do
      user = User.find(unhash(params[:id])).first
      present user
    end    



  end
end
