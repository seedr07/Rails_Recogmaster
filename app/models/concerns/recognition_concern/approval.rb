module RecognitionConcern
  module Approval
    extend ActiveSupport::Concern

    def approval_for(user)
      # self.approvals.where(giver_id: user.id).limit(1).first
      self.approvals.detect{|a| a.giver_id == user.id}
    end

    def approved_by?(user)
      self.approval_for(user).present?
    end

    def approvable_by?(user)
      if user.kind_of?(User)
        # must not be the sender or the recipient
        set = self.recipients + [self.sender]
        if !set.include?(user) 
          return true
        else
          return false
        end
      else 
        return false
      end
    end
    
    def has_approvals?
      return approvals.size > 0
    end

  end
end