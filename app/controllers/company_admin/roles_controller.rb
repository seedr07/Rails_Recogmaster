class CompanyAdmin::RolesController < CompanyAdmin::BaseController

  def index
    @company_roles = company.company_roles
  end

  def create
    @company_role = company.company_roles.build(roles_params)
    if @company_role.valid?
      @company_role.save
    else
      respond_with @company_role
    end
  end

  def show
    @company_role = company.company_roles.find(params[:id])
  end

  def edit
    @company_role = company.company_roles.find(params[:id])
  end

  def update
    @company_role = company.company_roles.find(params[:id])
    @company_role.name = roles_params[:name]
    @company_role.save

    if @company_role.errors.present?
      respond_with @company_role # use normal ajaxify
    else
      render action: "show" # bypass ajaxify, and force to update via js
    end
  end

  def destroy
    @company_role = company.company_roles.find(params[:id])
    @company_role.destroy
  end

  private

  def company
    @company
  end

  def roles_params
    params.require(:company_role).permit(:name)
  end
end
