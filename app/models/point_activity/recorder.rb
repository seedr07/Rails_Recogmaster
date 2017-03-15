class PointActivity
  module Recorder

    def self.record!(obj)
      case obj
      when Recognition
        RecognitionRecorder.record!(obj)
      when RecognitionApproval
        RecognitionApprovalRecorder.record!(obj)
      when Redemption
        RedemptionRecorder.record!(obj)
      else
        raise "Unsupported object: #{obj}"
      end      
    end

    class Base
      attr_reader :obj, :user

      def initialize(obj, user)
        @obj = obj
        @user = user
      end

      def record!
        before_recorded
        PointActivity.create!(attributes)
        after_recorded
      end

      def attributes
        {
          recognition: recognition,
          user: user,
          badge_id: recognition.badge_id,
          amount: amount,
          activity_object: obj,
          activity_type: activity_type,
          is_redeemable: is_redeemable?
        }
      end

      def activity_type
        self.class.to_s.demodulize.underscore.gsub(/_recorder/, '')
      end

      def is_redeemable?
        false # must be opt'd in by subclasses, and should check company settings #allow_rewards?
      end      

      # callback, can be called by subclasses
      def before_recorded
      end

      # callback, can be called by subclasses
      def after_recorded
      end

    end

    class RecognitionRecorder < Base
      alias :recognition :obj

      def self.record!(recognition)
        return if recognition.sender == User.system_user # don't count system recognitions in point totals

        RecognitionSenderRecorder.new(recognition, recognition.sender).record!
        recognition.recognition_recipients.includes(:user).each do |rr|
          user = rr.user ? rr.user : User.with_deleted.find(rr.user_id)
          RecognitionRecipientRecorder.new(recognition, user, rr.team_id).record!
        end      
      end

    end

    class RecognitionApprovalRecorder < Base
      delegate :recognition, to: :obj

      def self.record!(approval)
        RecognitionApprovalGiverRecorder.new(approval, approval.giver).record!
        approval.recognition.recognition_recipients.includes(:user).each do |rr|
          user = rr.user ? rr.user : User.with_deleted.find(rr.user_id)
          RecognitionApprovalReceiverRecorder.new(approval, user, rr.team_id).record!
        end

      end
    end

    class RedemptionRecorder < Base

      def self.record!(redemption)
        new(redemption, redemption.user).record!
      end

      def attributes
        {
          recognition: nil,
          user: user,
          badge_id: nil,
          amount: -(obj.reward.points),
          activity_object: obj,
          activity_type: activity_type,
          is_redeemable: true
        }
      end

      def after_recorded
        user.update_all_points!
      end      
    end

    class RecognitionRecipientRecorder < RecognitionRecorder
      attr_reader :team_id

      def initialize(obj, user, team_id)
        super(obj, user)
        @team_id = team_id
      end

      # Here we add in team id if necessary
      # If the recognition recipient has a team id attribute, 
      # the user was recognized as part of the team, and therefore
      # the points will be tagged as such. This will allow us to 
      # calculate team points and also give points to the member
      def attributes
        super.merge({team_id: team_id})
      end

      # def team_id
      #   recognition.recognition_recipients.with_deleted.for_user(user).team_id
      # end

      def amount
        recognition.badge.points
      end

      def after_recorded
        user.update_all_points!
      end

      def is_redeemable?
        user.company.allow_rewards?
      end
    end

    class RecognitionSenderRecorder < RecognitionRecorder
      def amount
        user.company.point_values[:sent_recognition_value]
      end

      def after_recorded
        user.update_all_points!
      end    
    end

    class RecognitionApprovalGiverRecorder < RecognitionApprovalRecorder
      def amount
        user.company.point_values[:sent_approval_value]
      end

      def after_recorded
        user.update_all_points!
      end    
    end

    class RecognitionApprovalReceiverRecorder < RecognitionApprovalRecorder
      attr_reader :team_id

      def initialize(obj, user, team_id)
        super(obj, user)
        @team_id = team_id
      end
            
      def attributes
        super.merge({team_id: team_id})
      end

      # def team_id
      #   recognition.recognition_recipients.with_deleted.for_user(user).team_id
      # end

      def amount
        user.company.point_values[:received_approval_value]
      end

      def after_recorded
        user.update_all_points!
      end 

    end

  end
end