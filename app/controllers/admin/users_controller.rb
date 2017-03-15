class Admin::UsersController < Admin::BaseController

  def index
    @users = User.order("created_at desc").paginate(page: params[:page], per_page: 100)
  end

  def search
    set = params[:company_id] ? Company.find(params[:company_id]).users : User
    @results = set.where("email like '%#{params[:q]}%'")
    respond_with @results
  end
end