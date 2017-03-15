class RecognitionsController < ApplicationController

  before_filter :require_network, except: [:show, :share, :certificate]
  before_filter :require_user, except: [:show, :share, :new, :index, :certificate]
  before_filter :require_user, only: [:index], unless: :has_secret_password?
  before_filter :redirect_personal_accounts, only: [:index], unless: :has_secret_password?
  before_filter :verify_user, only: :show, if: Proc.new{|c| params[:invite].present? }
  show_upgrade_banner only: [:index]

  filter_access_to :edit, :update, :show, :certificate, :toggle_privacy, :destroy, attribute_check: true

  skip_before_filter :set_send_recognition_form, only: [:recognize_instantly]







  # GET /recognitions
  # GET /recognitions.json
  def index
    @per_page_count = params["fullscreen"] == "true" ? 15 : 7


    #if we're not scoped, return compnay wide recognitions, otherwise get all of the users recognitions
    @recognitions = streamable_recognitions.paginate(:page => params[:page], :per_page => @per_page_count)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @recognitions }
    end
  end

  # GET /recognitions/1
  # GET /recognitions/1.json
  def show
    @recognition ||= Recognition.find_from_param(params[:id])
    raise ActiveRecord::RecordNotFound unless @recognition.kind_of?(Recognition)

    show_layout = params.has_key?(:skip_layout) ? false : true

    respond_to do |format|
      format.html { render "show", layout: show_layout}
      format.json { render json: @recognition }
    end
  end

  def certificate
    @recognition ||= Recognition.find_from_param(params[:id])
    raise ActiveRecord::RecordNotFound unless @recognition.kind_of?(Recognition)
  end

  # GET /recognitions/new
  # GET /recognitions/new.json
  def new

    @recognition = current_user.recognitions.new(params[:recognition])


    # FIXME: change to support multiple recipients via email addresses
    #        also, need to change recognitions/_new_form.html.erb
    @recognition.send(:convert_recipient_emails_to_user)
    @send_recipient = @recognition.user_recipients[0] if @recognition.user_recipients.present?

    @send_recognition = @recognition

    @user_team_map = current_user.company.user_team_map
    @pageName = "recognition"
    @jsClass = "Recognition"
    #@recipient =  User.where(slug: params[:recipient], network: params[:recipient_network]).first if params[:recipient] and params[:recipient_network]

    respond_to do |format|
      format.html {
        if params[:layout] === "false"
          render partial: "recognitions/new_form"
        else
          render action: "new"
        end
      }
      format.json { render json: @recognition }
    end
  end

  def new_chromeless
    @recognition = current_user.recognitions.new(recognition_params)
    @send_recognition = @recognition
    @pageName = "recognition"
    @jsClass = "Recognition"
    @user_team_map = current_user.company.user_team_map

    #@recipient = recipient_from_params

    render action: "new", layout: "application_chromeless"
  end

  # POST /recognitions
  # POST /recognitions.json
  def create

    @recognition = current_user.recognitions.new(recognition_params)

    #make sure we can't override the sender id or company
    @recognition.sender = current_user
    @recognition.save

    if @recognition.persisted?

      props = {role:  (current_user.company_admin? ? "company_admin" : "employee"), sent: true, badge: @recognition.badge.name}
      flash_add_prop_to_page_event(props)
    else
      # normalize the associated errors into the recognition object
      [:user_recipients, :team_recipients, :company_recipients].each do |r|
        @recognition.send(r).each do |recipient|
          if recipient.errors.present?
            @recognition.errors.add(:recipients, "#{recipient.email}:  #{recipient.errors.full_messages.to_sentence}")
          end
        end
      end
    end

    url = @recognition.persisted? ? recognition_path(@recognition) : nil
    respond_with @recognition, flash: {notice: "Your recognition has been sent"}, location: url
  end

  def edit
    @recognition = Recognition.find_from_param(params[:id])
    respond_with @recognition
  end

  def update
    @recognition = Recognition.find_from_param(params[:id])
    @recognition.update_attributes(recognition_params)

    respond_to do |format|
      format.html { redirect_to recognition_path(@recognition) }
      format.js {
        render js: "Turbolinks.visit('#{recognition_path(@recognition)}')"
      }
    end
  end

  # DELETE /recognitions/1
  # DELETE /recognitions/1.json
  def destroy
    @recognition = Recognition.find_from_param(params[:id])
    @recognition.destroy
    #
    respond_to do |format|
      format.html { redirect_to recognitions_url}
      format.js {render action: "destroy"}
    end
  end

  def toggle_privacy
    @recognition = Recognition.find_from_param(params[:id])
    if params[:make_public]
      @recognition.make_public!
    else
      @recognition.toggle_privacy!
    end
    respond_with @recognition
  end

  #You can permalink to share a recognition
  def share
    @recognition = Recognition.find_from_param(params[:id])
    raise ActiveRecord::RecordNotFound unless @recognition.present?

    @recognition.make_public! if permitted_to? :toggle_privacy
    redirect_to SocialShare.new(params[:provider],
      render_to_string(partial: "recognitions/title", locals: {recognition: @recognition}),
      recognition_url(@recognition), @recognition.message).url
  end

  def recognize_instantly
    @recognition = Recognition.instant(current_user, recognition_params)

    if @recognition.save
      @recipient = @recognition.recipients.first
      @recipient.update_attribute(:yammer_id, params[:recognition][:yammer_id]) if params[:recognition][:yammer_id].present?

      response_params = {
        name: "recognition_create",
        recognition_id: @recognition.id,
        person_id: @recipient.id,
        yammer_id: @recipient.yammer_id,
        recognition_url: recognition_url(@recognition)
      }
    else

      response_params = {
        name: "recognition_error",
        recognition_id: @recognition.id,
        # errors: "There was an error please refresh and try again"
        errors: @recognition.errors.full_messages.to_sentence
      }
    end

    respond_with @recognition,
      onsuccess: {
        method: "fireEvent",
        params: response_params
      }

  end

  def has_secret_password?
    if @company.kiosk_mode_key.present? && (@company.kiosk_mode_key != "") && (params[:code] == @company.kiosk_mode_key)
      return true
    else
      return false
    end
  end

  protected



  def recognition_params
    params[:recognition] ?
      params.require(:recognition).permit(
        :sender_id, :badge_id, :email, :yammer_id, :post_to_yammer_wall,
        :message, :sender, {:recipients => []}, :badge,
        {:recipient_emails => []}, :skills, :reason, :experiment_value) :
      params.permit
  end

  def permission_denied
    if current_user
      super
    else
      if params[:action] == "new"
        redirect_to recognize_signups_path
      else
        super
      end
    end
  end

  def verify_user
    @invited_user = User.find_by_perishable_token(params[:invite])
    if @invited_user
      @invited_user.verify! if @invited_user.invited_from_recognition? and !@invited_user.verified?
      @recognition ||= Recognition.find_from_param(params[:id])
      @recognition.allow_guest_access = true if @recognition.present?
    end
  end

  def require_network
    unless params[:network]
      redirect_to "/#{current_user.network}#{request.fullpath}"
    end
  end

  def streamable_recognitions
    Recognition.streamable_recognitions(user: current_user, network: params[:network], company: @company)
  end

  def redirect_personal_accounts
    if current_user.personal_account?
      redirect_to user_path(current_user) and return false
    end
  end
end
