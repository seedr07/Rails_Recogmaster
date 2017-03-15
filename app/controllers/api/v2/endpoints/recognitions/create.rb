class Api::V2::Endpoints::Recognitions::Create < Api::V2::Endpoints::Recognitions
  resource :recognitions, desc: '' do
    desc 'Create a recognition' do
      # success Api::V2::Endpoints::Recognitions::Entity
    end
    params do
      requires :recipients, desc: "Comma seperated list of emails"
      optional :badge, desc: "Badge name or id"
      optional :message
    end

    oauth2 'write'
    post '/' do
      recipients = params[:recipients].split(",")
      recognition = current_user.recognize!(recipients, params[:badge], params[:message])
      present recognition
    end

    ########################################################################################
    desc 'Create a recognition and ensure recipients are in senders network' do
      # success Api::V2::Endpoints::Recognitions::Entity
    end
    params do
      requires :recipients, desc: "Comma seperated list of emails"
      optional :badge, desc: "Badge name or id"
      optional :message
    end

    oauth2 'trusted'
    post '/force_network' do
      emails = params[:recipients].split(",").map(&:strip)
      recipients = emails.map{|email| ExternalUserCreator.create(email: email, network: current_user.network).user}
      recognition = current_user.recognize!(recipients, params[:badge], params[:message])
      present recognition
    end

  end
end