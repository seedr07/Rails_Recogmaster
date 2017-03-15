require "will_paginate/array"
class TeamsController < ApplicationController
  before_filter :set_team, only: [:show, :edit, :update, :destroy]
  filter_access_to :edit, :update, :show, :destroy, attribute_check: true
  show_upgrade_banner only: [:index]
  layout "company_admin", only: :nominations
  
  def index

    @user = current_user
    #sorts by presence of user in team, then alphabetically
    @users_teams = current_user.teams.includes(users: :avatar).order("teams.name asc")
    @other_teams = @company.teams.includes(users: :avatar).where.not(teams: {id: @users_teams.map(&:id)}).order("teams.name asc")
    # @teams = @company.teams.includes(users: :avatar).sort_by{|team| [@user.teams.include?(team) ? 0 : 1, team.name]}
    

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @teams }
    end
  end

  def create
    @team = current_user.create_team!(params[:team])

    render nothing: true    

  end
  
  def show
    @recognitions = @team.received_recognitions.paginate(:page => params[:page], :per_page => 10)
  end
  
  def edit
  end
  
  def update
    if @team.update_attributes(params[:team])
    else
    end
  end
  
  def destroy
    @team.destroy

    respond_to do |format|
      format.html { redirect_to teams_url }
      format.js { render js: "$('##{dom_id(@team)}').remove()" }
    end
  end

  def add_members
    render action: "add_members", layout: false
  end

  def nominations
    @team = Team.find_by(id: params[:id])
    @nominations = Nomination.for_recipient(@team).where(badge_id: params[:badge_id])
    @nominations = @nominations.for_sender(current_user) unless current_user.company_admin?
  end

  protected

  def set_team
    @team = @company.teams.find(params[:id])  if current_user
  rescue ActiveRecord::RecordNotFound => e
    flash[:error] = "Sorry, that team does not exist."
    redirect_to root_path and return false
  end
end
