require 'will_paginate/array'
class Api::V2::Endpoints::Users::Search < Api::V2::Endpoints::Users
  resource :users, desc: '' do
    # GET /users/search
    desc 'Search for a user' do
      detail 'You may only get info about users in your network'
    end

    params do
      requires :query, type: String
      optional :limit, type: Integer
      optional :include_self, type: Boolean
    end

    paginate per_page: 20, max_per_page: 100

    oauth2 'read'
    get '/search' do

      query= params["query"]
      include_self = !!params["include_self"]
      
      set = current_user.coworkers(query, include_self: include_self)
      paged = paginate(set)
      present paged
    end    


  end
end
