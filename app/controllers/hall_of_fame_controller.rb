class HallOfFameController < ApplicationController
  filter_access_to :index, attribute_check: true, load_method: :current_user
  show_upgrade_banner only: [:index]

  def index
    @hall_of_fame = HallOfFame.new(@company, current_user, params)
    @current_winners_groups = @hall_of_fame.current_winners_grouped_by_period
    if params[:group_by] && params[:group_by] == "team"
      @winners_by_team = @hall_of_fame.by_team
    else
      @winners_by_badge = @hall_of_fame.by_badge
    end
    @team = @company.teams.find(params[:team_id]) if params[:team_id].present?
    @badge = @company.company_badges.find(params[:badge_id]) if params[:badge_id].present?
  end

  private
  def user_map
    @user_map ||= @company.family_users(includes: :avatar).inject({}){|map,user| map[user.id] = user;map}
  end
  helper_method :user_map

end