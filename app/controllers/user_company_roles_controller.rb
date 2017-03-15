class UserCompanyRolesController < ApplicationController
  def create
    user.company_roles.add(role)
    render nothing: true
  end

  def destroy
    user.company_roles.remove(role)
    render nothing: true
  end

  private

  def user
    @user ||= company.users.find(params[:user_id])
  end

  def role
    @role ||= company.company_roles.find_by(name: params[:role_name])
  end

  def company
    @company
  end
end
