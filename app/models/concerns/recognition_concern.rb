module RecognitionConcern
  extend ActiveSupport::Concern
  
  included do
    include Approval
    include Display
    include Privacy
    include Notification
  end
end