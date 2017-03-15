module RecognitionConcern
  module Privacy
    extend ActiveSupport::Concern

    def toggle_privacy!
      if self.is_public
        # we can always make it private
        update_attribute :is_public, false
      else
        # however, company global privacy flag must be off to make public
        if self.sender_company.allows_public_recognitions?
          update_attribute :is_public, true
        end
      end
    end

    def make_public!
      update_attribute :is_public, true if self.sender_company.allows_public_recognitions?
    end

    def is_private?
      !is_public?
    end

    protected
     
    def set_privacy
      if self.sender_company
        self.is_public = self.sender_company.allows_public_recognitions?
      end
      return true
    end
  end
end