class CompaniesController < ApplicationController
  include CompanyAdminConcern

  filter_access_to :show, :update, :update_privacy, 
    :add_users, :update_point_values, :update_recognition_limits, 
    :update_settings, attribute_check: true
  show_upgrade_banner only: [:show]

  respond_to :csv, :xls#, :pdf
  after_filter :add_attachment_headers, only: :recognitions

  attr_accessor :check_list

  def show
    @support_email = SupportEmail.new
    @support_email.type = params[:type]

    @res_calculator = ResCalculator.new(@company)

    @company = Company.includes(users: :user_roles).find_by_domain(scoped_network)
    @users = User.where(company_id: @company.id).includes(:user_roles)
    @roles = collect_anniversary_roles
    @teams = @company.teams

    @recognitions = Recognition.for_company(@company).user_sent
    @badge = @company.badges.build


    @attribute = params[:sort].try(:to_sym) || :received_recognitions
    @time_period = Time.now.prev_month.all_month
    @report = Report::Company.new(@company, @time_period.first, @time_period.last)

    @top_badges = @company.top_badges
    @non_deletable_badge_ids = Recognition.select("distinct badge_id").where(sender_company_id: 1).pluck(:badge_id)
    @company_roles = @company.company_roles
    @saml_configuration = @company.saml_configuration || @company.build_saml_configuration
  end

  def update
    @company.update_global_privacy(params[:privacy])
  end

  def recognitions
    params[:use_reference_recipients] = true
    from = params[:from]
    to = params[:to]
    @recognition_report = Report::Recognition.new(@company, from, to, params)
    respond_with @recognition_report, serializer: RecognitionReportSerializer, root: false
  end

  def update_privacy
    @company.update_global_privacy(params[:privacy])
    render nothing: true
  end

  def update_point_values
    @company.update_point_values(params[:company])
    flash[:notice] = "Successfully updated point values" if @company.errors.count == 0
    render nothing: true
  end

  def update_kiosk_mode_key
    key = params[:company][:kiosk_mode_key]
    key.gsub!(/\s+/, "")
    @company.update_kiosk_mode_key(key)
    kiosk_url_partial = render_to_string(partial: "companies/kiosk_url")
    respond_with @company, onsuccess: {method: "fireEvent", params: {name: "kioskUrlUpdated", kiosk_url_partial:  kiosk_url_partial}}
  end

  def update_recognition_limits
    @company.update_recognition_limits(params[:company])
    #flash[:notice] = "Successfully updated badge sending limits" if @company.errors.count == 0
    render nothing: true
  end

  def accounts
    @users = @company.users
  end

  def bulk_update
  end

  def add_users
    @company.add_users!(params[:company][:users], skip_cache_refreshing: true)
    flash[:notice] = "Users successfully added" if @company.persisted?
    # respond_with @company, location: admin_company_path(@company)
    respond_with @company, location: request.referer
  end

  def update_settings
    @company.update_settings!(params[:settings].slice(*allowable_settings))
    render nothing: true
  end

  def reports
    @attribute = params[:sort].try(:to_sym) || :received_recognitions
    @badge = Badge.cached(params[:badge_id]) if params[:badge_id]
    if params[:team_id]
      @team = current_user.company.teams.find(params[:team_id])
    end
    @report = Report::Company.new(@company, start_date, end_date, badge_id: @badge.try(:id), team_id: @team.try(:id))
    @team_members = @report.user_leaderboard(@attribute)
  end

  def resend_invitation_email
    @user = @company.users.where(email: params[:email]).first
    @user.update_columns(invited_by_id: current_user.id, invited_at: Time.now)
    @user.reset_perishable_token! if @user.perishable_token.blank?
    UserNotifier.delay(queue: 'priority').invitation_email(@user)
  end

  protected

  def allowable_settings
    Company::SETTINGS
  end

  #collect all roles should return actual roles instead of the names of the roles.
  #later on you can extract the names of the roles.  this should also be moved to company.rb
  #also let's rename it collect all anniversary rolesaa.
  def collect_anniversary_roles
    role_names = ["Company Admin", "Executive"]
    roles = []
    role_names.each do |role_name|
      roles << Role.find_by_long_name(role_name)
    end
    return roles
  end

  def start_date
    @start_date ||= if params[:start_date].present?
      # current_user.interval_start_date(time: Time.at(params[:start_date].to_i))
      Time.at(params[:start_date].to_i)
    else
      current_user.interval_start_date
    end
  end

  def end_date
    @end_date ||= if params[:end_date].present?
      # current_user.interval_end_date(time: start_date)
      Time.at(params[:end_date].to_i)
    else
      current_user.interval_end_date
    end
  end

  def add_attachment_headers
    response.headers['Content-Disposition'] = 'attachment; filename="' + 'recognitions' + '.'+params[:format]
  end

end
