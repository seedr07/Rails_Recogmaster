module UnsubscribeConcern
  extend ActiveSupport::Concern

  def unsubscribe_token
    self.class.verifier.generate(self.id)
  end

  def unsubscribe!
    self.email_setting.unsubscribe!
  end

  module ClassMethods
    def verifier
      ActiveSupport::MessageVerifier.new(Rails.configuration.secret_token)
    end
  
    def read_unsubscribe_token(token)
      id = verifier.verify(token)
      User.find_by_id id
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      nil
    end    
  end
end