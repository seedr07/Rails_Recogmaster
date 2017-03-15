require "will_paginate/array"
class BadgesController < ApplicationController
  show_upgrade_banner only: [:index]

  def index
    @badges = current_user.company.company_badges
  end

  def show
    @badge = current_user.company.company_badges.find(params[:id])
    @recognitions = current_user.company.recognitions_for_badge(params[:id]).paginate(:page => params[:page], :per_page => 15)
  end

  def new
    @badge = @company.badges.build
  end

  def create
    @badge  = Badge.new(params[:badge])
    @badge.company = @company
    @badge.save

    if handle_ie_stupidity?
      handle_ie_stupidity

    else
      if @badge.persisted?
        @company_roles = @company.company_roles
        render json: { partial: render_to_string(partial: "companies/badge", locals: {badge: @badge}) }
      else
        respond_with @badge
      end
    end
  end

  def update_all
    result = @company.update_badges!(params[:company][:badges])
    if result.success
      flash[:notice] = "Successfully updated badges"
      redirect_to company_path(anchor: "custom_badges", dept: @company.domain)
    else
      # FIXME: this shouldn't redirect t
      flash[:error] = "There was an error with one or more of the badges.  Please see the highlighted badges below."      
      flash[:badge_errors] = result.badges.reject(&:valid?).inject({}){|hash, badge| hash[badge.id] = badge.errors.full_messages;hash}
      redirect_to company_path(anchor: "custom_badges", dept: @company.domain)
    end

  end

  def destroy
    @badge = Badge.find(params[:id])
    @badge.destroy if @badge.can_destroy?
  end

  private
  def handle_ie_stupidity?
    !request.headers["HTTP_ACCEPT"].match(/application\/json|application\/javascript/)
  end

  def handle_ie_stupidity
    request.format = 'json'

    resource = JsonResource.new(@badge, self, [], {})
    if resource.has_errors?
      status = 422
      render :json => resource.to_json, :content_type => "text/plain", status: status
    else
      status = 200
      render json: { partial: render_to_string(partial: "companies/badge", content_type: "text/plain", locals: {badge: @badge}) }

    end

  end
end