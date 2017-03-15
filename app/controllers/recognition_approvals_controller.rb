class RecognitionApprovalsController < ApplicationController
  skip_before_filter :ensure_correct_company
  def create
    
    # @approval = RecognitionApproval.new(recognition_id: Recognition.find(params[:recognition_id]).id, giver: current_user)
    
    recognition = Recognition.find(params[:recognition_id]) 
    @approval = recognition.approve_by(current_user)

    # need to reload the associated objects for the point calculator
    # ugly, i know...
    @approval.giver.reload 
    @approval.recognition.reload 

    if !@approval.persisted?
      # why didn't it save?
      ExceptionNotifier.notify_exception(Exception.new("Could not save recognition approval"), data: {errors: @approval.errors.full_messages.to_sentence})
    end
    
    @approval.delay(queue: 'priority').post_yammer_activity!(Recognize::Application.yammer_client) if @approval.persisted? and current_user.authenticated_with_yammer?(Recognize::Application.yammer_client)
  end
  
  def destroy
    @approval = RecognitionApproval.joins(:recognition).includes(:recognition).find(params[:id])
    
    @approval.destroy! # don't hide, do full wipe
    
    # need to reload the associated objects for the point calculator
    # ugly, i know...
    @approval.giver.reload
    @approval.recognition.reload
    
  end

end