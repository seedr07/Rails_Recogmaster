class Api::V2::Endpoints::Badges::Index < Api::V2::Endpoints::Badges
  resource :badges, desc: '' do
    desc 'Returns a list of badges' do
    end

    paginate per_page: 1000, max_per_page: 1000
    oauth2 'read'
    get '/' do
      set = current_user.company.company_badges
      paged = paginate(set)
      present paged
    end
  end
end