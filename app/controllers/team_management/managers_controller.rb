class TeamManagement::ManagersController < TeamManagement::BaseController
  def edit
    render_people_picker(@team, Teams::ManagerUpdater.new(team_manager_updater_params), team_managers_path)
  end

  def update
    updater = Teams::ManagerUpdater.new(team_manager_updater_params)
    updater.save
    respond_with updater, location: team_path(@team)
  end

  private
  def team_manager_updater_params
    {team: @team}.merge(params[:teams_manager_updater] || {})
  end
end