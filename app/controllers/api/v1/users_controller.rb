class Api::V1::UsersController < Api::V1::BaseController
  include Seahorse::Controller
  include AuthenticatedController
  include ApplicationHelper


  def index
    output = {users: users}
    respond_with output
  end

  private

  def users
    set = current_user.company.users
    return set
  end  
end