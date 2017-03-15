module Api
  class User
    include Seahorse::Model

    type :user do
      model ::User
      integer :id
      string :email
      string :first_name
      string :last_name
      string :full_name
      string :company_name
      string :yammer_id
      string :avatar_thumb_url
      string :company_admin?
    end

    operation :index do
      url '/users'

      output do
        list(:users) { user }
      end
    end    
  end
end