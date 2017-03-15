WineBouncer.configure do |config|
  config.auth_strategy = :swagger

  config.define_resource_owner do |thing|
    if doorkeeper_access_token
      
      if doorkeeper_access_token.resource_owner_id
        User.find(doorkeeper_access_token.resource_owner_id)
      
      else  
        # No Resource owner, therefore we need to require XAuthEmail 
        # unless route has explictly stated, its not required
        if !x_auth_email[:required] && !x_auth_email[:optional]
          nil
        elsif headers['X-Auth-Email'].blank? || headers['X-Auth-Network'].blank?
          # If missing XAuthEmail and its optional, that's cool
          if x_auth_email[:optional]
            nil
          else
            error = Api::V2::InvalidHeaderResponse.new(:missing_email_auth_headers)
            raise(WineBouncer::Errors::OAuthUnauthorizedError, error) 
          end
        else
          user = User.find_by(email: headers['X-Auth-Email'], network: headers['X-Auth-Network'])
          if user.blank?
            if x_auth_email[:optional]
              nil
            else
              error = Api::V2::InvalidHeaderResponse.new(:email_auth_headers_invalid)
              raise(WineBouncer::Errors::OAuthUnauthorizedError, error) 
            end
          end
          user
        end # if !x_auth_email[:required]

      end # if resource_owner_id
    end # if doorkeeper_access_token
  end # define_resource_owner
end # WineBouncer.configure
