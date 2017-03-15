class Api::V1::RecognitionsController < Api::V1::BaseController
  include Seahorse::Controller
  include AuthenticatedController
  include ApplicationHelper

  def index
    page_size, page = 30, params[:page] || 1
    offset = (page - 1) * page_size    

    output = {recognitions: recognitions.limit(page_size).offset(offset)}
    output[:next_page] = recognitions.count > (offset + page_size) ? page + 1 : nil
    if output[:recognitions].present?
      respond_with output
    else
      #NOTE: this is not restful.  This should be handled by clients
      raise ArgumentError, "This user has no recognitions."
    end
  end

  def new
    opts = {network: (yammer_user || current_user).network, recognition: {message: params[:message]}}

    if yammer_user
      url = user_recognition_url(yammer_user, opts.merge(chromeless: true))
    else
      url = new_chromeless_recognitions_url(opts)      
    end

    output = {url: url}
    respond_with output
  end

  def instant
    @recognition = Recognition.instant(current_user, recognition_params)

    if @recognition.save
      @recognition.recipients.first.update_attribute(:yammer_id, recognition_params[:yammer_id]) if recognition_params[:yammer_id].present?
    end

    respond_with @recognition
  end

  def search
    page_size, page = 30, params[:page] || 1
    offset = (page - 1) * page_size    

    output = {recognitions: recognitions.where(slug: params[:slugs].split(",")).limit(page_size).offset(offset)}
    output[:next_page] = Recognition.count > (offset + page_size) ? page + 1 : nil


    respond_with output

  end

  def approve
    recognition = Recognition.where(slug: params[:slug]).first

    if recognition
      recognition.approvals.create!(giver: current_user)
      recognition.reload
    end

    respond_with recognition
  end
  
  def unapprove
    recognition = Recognition.where(slug: params[:slug], giver: current_user).first
    if recognition
    end
    respond_with recognition
  end
  
  private

  def recognition_params
    params.permit(:email, :yammer_id, :message, :yammer_thread_uid)
  end

  def yammer_user
    @yammer_user ||= if params[:yammer_id].present? 
        User.by_yammer_id(params[:yammer_id], current_user.yammer_client)
      else
        nil
      end
  end

  def recognitions
    set = yammer_user ? yammer_user.recognitions.includes(:badge) : current_user.company.recognitions.includes(:recognition_recipients)
    # FIXME: the performance of this could be improved
    if params[:email]
      recipient = User.where(email: params[:email]).first 
      set = set.select{|recognition| recognition.sender_id== recipient.id || recognition.recognition_recipients.any?{|rr| rr.user_id == recipient.id }}
      set = Recognition.where(id: set.map(&:id))
    else
      # protect against cross-network requests to show only public recognitions
      set =set.where(is_public: true) if yammer_user && (yammer_user.try(:network) != current_user.try(:network))
  
    end

    return set
  end

end