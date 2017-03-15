class ReportsController < ApplicationController
  show_upgrade_banner only: [:index]

  def index
    start_date
    end_date
    @badge = get_badge_by_params
  end

  def users
    @badge = get_badge_by_params
    @report = Report::Company.new(current_user.company, start_date, end_date, badge_id: params[:badge_id])
    render action: "users", layout: false
  end

  def teams
    @badge = get_badge_by_params
    @report = Report::Company.new(current_user.company, start_date, end_date, badge_id: params[:badge_id])
    render action: "teams", layout: false
  end

  def top_users
    @attribute = params[:sort].try(:to_sym)
    @badge = Badge.cached(params[:badge_id]) if params[:badge_id]
    @report = Report::Company.new(@company, start_date, end_date, badge_id: @badge.try(:id))
    @top_users = @report.user_leaderboard(:points)
  end

  private
  def start_date
    @start_date ||= if params[:start_date].present?
      Time.at(params[:start_date].to_i)
    else
      current_user.interval_start_date
    end
  end

  def end_date
    @end_date ||= if params[:end_date].present?
      Time.at(params[:end_date].to_i)
    else
      current_user.interval_end_date
    end
  end

  def get_badge_by_params()
    Badge.cached(params[:badge_id]) if params[:badge_id].present?
  end
end
