module LeaderboardHelper
  def leaderboard_report_path_method
    case 
    when on_company_nominations_controller?
      :company_admin_nominations_path
    when on_company_controller?
      :company_path      
    else
      :reports_path
    end
  end

  def leaderboard_path_args
    args = {badge_id: @badge.try(:id), start_date: params[:start_date], team_id: @team.try(:id), end_date: params[:end_date], interval: params[:interval]} 
    args.merge!({anchor: "rank", sort: params[:sort]}) if on_company_controller?
    args.merge!({archive: params[:archive]}) if on_company_nominations_controller?
    args
  end

  def show_leaderboard_team_filter?
    on_company_controller?
  end

  def show_leaderboard_metric_selector?
    on_company_controller?
  end

  def leaderboard_class
    on_company_controller? ? "company_leaderboard" : "user_leaderboard"
  end

  private
  def on_company_controller?
    controller.class == CompaniesController
  end

  def on_company_nominations_controller?
    controller.class == CompanyAdmin::NominationsController
  end
end