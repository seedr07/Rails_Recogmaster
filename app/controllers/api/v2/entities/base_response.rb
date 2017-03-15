module Api
  module V2
    module Entities
      class BaseResponse < Grape::Entity
        expose :ok, documentation: { required: true, type: String, desc: "Either 'success' or 'error'" }
        expose :type, documentation: { required: true, type: String, desc: 'The entity type of the response. Ex. Recognition, User, Collection' }

        def endpoint
          self.options[:env]["api.endpoint"]
        end

        def type
          case self.object
          when Hash
            "Object"
          else
            self.object.class.to_s
          end
        end

        def ok
          "success"
        end
      
      end

      # class CollectionResponse < BaseResponse
      #   expose :page, documentation: {required: true, type: Integer, desc: 'The current page retrieved of the collection'}
      # end
    end
  end
end