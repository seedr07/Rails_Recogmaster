class PointActivity
  module Destroyer
    def self.destroy!(obj)
      Rails.logger.info "DESTROYING #{obj.class}-#{obj.id}"
      Recognition.transaction do
        case obj
        when Recognition
          RecognitionDestroyer.destroy!(obj)
        when RecognitionApproval
          RecognitionApprovalDestroyer.destroy!(obj)
        when Redemption
          # no special ops needed
        else
          raise "Unsupported object: #{obj}"
        end
      end
    end

    class Base
      attr_reader :obj, :user
      
      def initialize(obj, user)
        @obj = obj
        @user = user
      end

      # def activities
      #   raise "must be implemented by subclass"
      # end

      def activities
        PointActivity.for_activity(obj, user)
      end

      def activity_type
        self.class.to_s.demodulize.underscore.gsub(/_recorder/, '')
      end

      def destroy!
        before_destroyed
        activities.destroy_all
        after_destroyed      
      end

      # callback, can be called by subclasses
      def before_destroyed
      end

      # callback, can be called by subclasses
      def after_destroyed
      end      
    end

    class RecognitionDestroyer < Base
      alias :recognition :obj

      def self.destroy!(recognition)
        return if recognition.sender == User.system_user # don't count system recognitions in point totals

        RecognitionSenderDestroyer.new(recognition, recognition.sender).destroy!
        recognition.flattened_recipients.each do |user|
          RecognitionRecipientDestroyer.new(recognition, user).destroy!
        end      
      end      
    end

    class RecognitionApprovalDestroyer < Base
      delegate :recognition, to: :obj

      def self.destroy!(approval)
        RecognitionApprovalGiverDestroyer.new(approval, approval.giver).destroy!
        approval.recognition.flattened_recipients.each do |user|
          RecognitionApprovalReceiverDestroyer.new(approval, user.reload).destroy! # need to reload user object for some reason
        end

      end
    end  

    class RecognitionRecipientDestroyer < RecognitionDestroyer

      def after_destroyed
        user.update_all_points!
      end
    end

    class RecognitionSenderDestroyer < RecognitionDestroyer

      def after_destroyed
        user.update_all_points!
      end    
    end

    class RecognitionApprovalGiverDestroyer < RecognitionApprovalDestroyer

      def after_destroyed
        user.update_all_points!
      end    
    end

    class RecognitionApprovalReceiverDestroyer < RecognitionApprovalDestroyer

      def after_destroyed
        user.update_all_points!
      end    
    end

  end
end