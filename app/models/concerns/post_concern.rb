# methods relating to both Recognition or Nomination
module PostConcern
  extend ActiveSupport::Concern

  included do    
  end

  module ClassMethods
    def find_recipient_from_signature(sig)
      klass, id = sig.split(":")
      klass.constantize.find(id)
    end
  end
end