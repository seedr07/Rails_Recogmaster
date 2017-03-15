class Api::V2::Endpoints::Users::Create < Api::V2::Endpoints::Users
  resource :users, desc: '' do
    desc 'Create a new user' do
      # success Entity
    end

    params do
      requires :email, type: String
      requires :first_name, type: String
      requires :last_name, type: String
    end

    oauth2 
    route_setting(:x_auth_email, required: false)
    
    post '/' do
      # params[:email] = rand(1000).to_s + "email@email.com"
      user = User.new(params)
      user.save
      present user
    end    

    #
    # Trusted User Create
    # Allows Slack microservice(and other trusted apps) to explictly specify which network
    # a user should belong to upon creation
    #
    desc 'Create a new user and allow explicit setting of network | Requires TRUSTED oauth scope'
    params do
      requires :email, type: String
      requires :first_name, type: String
      requires :last_name, type: String
      requires :network, type: String
    end

    oauth2 'trusted'
    route_setting(:x_auth_email, required: false)
    
    post '/create_with_network' do
      creator = ExternalUserCreator.create(params)
      user = creator.user
      present user
    end    

  end
end
