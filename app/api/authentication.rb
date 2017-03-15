module Api
  class Authentication
    include Seahorse::Model
    
    type :yammer_authentication do
      boolean :status
      boolean :yammer
      string :yammer_id
      string :time
      string :company_admin
      string :network
    end

    type :basic_authentication do
      boolean :status
      integer :user_id
    end

    desc 'Ping to test authentication'
    operation :ping do
      url '/ping'

      input do 
        string :username
      end
      
      output :yammer_authentication
    end

    desc 'Authentication status'
    operation :auth_status do
      url '/auth_status'
      
      output :basic_authentication
    end    
  end
end
