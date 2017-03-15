class Admin::CompaniesController < Admin::BaseController
  before_filter :set_company
  def show
    @users = @company.users.includes(:authentications, :user_roles).not_disabled
    @subscription = @company.subscription || Subscription.new(user_count: @company.users.size)
  end

  def create
    new_company = @company.make_child_company!(params[:company][:domain])
    respond_with new_company, location: admin_company_path(@company)
  end

  def enable_custom_badges
    @company.enable_custom_badges!
  end

  def enable_admin_dashboard
    @company.enable_admin_dashboard!
  end

  def enable_theme
    @company.enable_theme!
  end

  def enable_achievements
    @company.enable_achievements!
  end

  def add_users
    @company.add_users!(params[:company][:users], optimize_cache_refreshing: true)
    flash[:notice] = "Users successfully added" if @company.persisted?
    # respond_with @company, location: admin_company_path(@company)
    respond_with @company, location: request.referer
  end

  def add_directors
    @user = @company.add_director!(params[:user][:email])
  rescue Exception => e
    @error = e.message
  end

  def remove_directors
    @user = @company.remove_director!(params[:user_id])
  rescue Exception => e
    @error = e.message
  end
  
protected
  def set_company
    @company = Company.where(domain: params[:id]).first    
    raise ActionController::RoutingError.new('Not Found') unless @company.present?
  end
end