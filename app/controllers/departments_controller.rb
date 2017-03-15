class DepartmentsController < ApplicationController
  before_filter :set_company_from_network

  def index
  end

  def destroy
    @department = @company.child_companies.find(params[:id])
    @department.destroy
  end

  private
  # this psuedo-hack lets declarative authorization play nicely and redirect
  # to login when not logged in
  def set_company_from_network
    @company = Company.where(domain: params[:network]).first
  end  
end