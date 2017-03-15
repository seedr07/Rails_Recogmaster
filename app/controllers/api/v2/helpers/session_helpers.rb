module Api
  module V2
    module Helpers
      module SessionHelpers
        def current_token
          doorkeeper_access_token
        end
        
        def current_user
          resource_owner
        end

        def current_scopes
          current_token.scopes
        end

        def authorize!
          current_user
        end
      end
    end
  end
end
