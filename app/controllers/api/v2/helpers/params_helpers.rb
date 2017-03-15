module Api
  module V2
    module Helpers
      module ParamsHelpers
        extend Grape::API::Helpers
        params :pagination do
          optional :page, type: Integer
          optional :per_page, type: Integer
        end 
      end
    end
  end
end
