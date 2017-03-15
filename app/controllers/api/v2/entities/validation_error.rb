module Api
  module V2
    module Entities
      class ValidationError < ErrorResponse
        def errors
          errors = self.exception.record.errors
          map = {}
          errors.messages.each do |attr, message|
            map[attr] = errors.full_messages_for(attr)
          end
          map
        end
      end   
    end
  end
end
