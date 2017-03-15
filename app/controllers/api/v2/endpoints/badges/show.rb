class Api::V2::Endpoints::Badges::Show < Api::V2::Endpoints::Badges
  resource :badges, desc: '' do

    # GET /badges/:id
    desc 'Show info about a badge, searching by id' do
      detail 'You may only get info about badges in your network'
    end
    params do
      requires :id, type: String
    end

    oauth2 'read'
    get '/:id' do
      badge = current_user.company.company_badges.find(unhash(params[:id])).first
      present badge
    end    



  end
end
