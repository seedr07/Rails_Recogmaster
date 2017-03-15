class Api::V2::Endpoints::Recognitions::Index < Api::V2::Endpoints::Recognitions
  resource :recognitions, desc: '' do
    desc 'Returns a list of recognitions' do
      # success Api::V2::Endpoints::Recognitions::Entity
    end

    paginate per_page: 20, max_per_page: 100

    oauth2 'read'
    get '/' do
      set = current_user.company.recognitions
      paged = paginate(set)
      present paged
    end
  end
end