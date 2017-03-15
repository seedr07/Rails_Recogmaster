module AuthenticatedController
  extend ActiveSupport::Concern
  class Unauthorized < Seahorse::Exception
    status 401
    def self.name; "Unauthorized"; end
  end

  included do
    before_filter :require_authentication
  end
  
  private

  def require_authentication
    unless current_user.present?
      raise Unauthorized, "You must be logged in for this action"
    end
  end

end