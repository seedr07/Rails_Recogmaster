class TeamManagement::MembersController < TeamManagement::BaseController
  def edit
    render_people_picker(@team, Teams::MemberUpdater.new(team_member_updater_params), team_members_path)
  end

  def update
    updater = Teams::MemberUpdater.new(team_member_updater_params)
    updater.save
    respond_with updater, location: team_path(@team)
  end

  private
  def team_member_updater_params
    {team: @team}.merge(params[:teams_member_updater] || {})
  end
end