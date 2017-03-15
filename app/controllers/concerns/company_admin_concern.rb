module CompanyAdminConcern
  extend ActiveSupport::Concern

  included do
    before_filter :require_user
    before_filter :set_company_from_network, except: :show    
    before_filter :restrict_to_company_admin
  end

  private

  def restrict_to_company_admin
    unless current_user.admin? || current_user.company_admin?
      flash[:notice] = "You must be the company adminstrator to access this page"
      redirect_to login_path and return false
    end
  end

  def scoped_network
    params[:dept].presence || params[:network].presence
  end  

  # this psuedo-hack lets declarative authorization play nicely and redirect
  # to login when not logged in
  def set_company_from_network
    @company = Company.where(domain: scoped_network).first
  end  

end