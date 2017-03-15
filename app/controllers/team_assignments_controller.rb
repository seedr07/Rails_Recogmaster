class TeamAssignmentsController < ApplicationController
  def create
    current_user.add_team!(params[:team_id])
    render nothing: true
  end

  def destroy
  	current_user.remove_team!(params[:team_id])
  	render nothing: true
  end

  private
  def teams_params
    params[:user][:team_names]
  end
end