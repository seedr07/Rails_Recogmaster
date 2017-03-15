class Points::ChangeObserver < ActiveRecord::Observer
  observe :recognition, :recognition_approval, :redemption
  
  def after_create(obj)
    PointActivity::Recorder.record!(obj)
  end

  def after_destroy(obj)
    PointActivity::Destroyer.destroy!(obj)
  end

protected
  
  # def handle(obj)
  #   return unless obj.kind_of?(Recognition) || obj.respond_to?(:recognition) && obj.recognition.present?
    
  #   case obj
  #   when Recognition
  #     participants = obj.participants
  #   when RecognitionApproval
  #     participants = [obj.giver, obj.recognition.sender] + obj.recognition.flattened_recipients rescue []
  #   else
  #     raise "model not handled: #{model}"
  #   end    

  #   teams = []
  #   participants.each do |user|
  #     user.update_all_points!
  #     teams += user.teams
  #   end

  #   teams.uniq.map(&:update_all_points!)
  # end

end
