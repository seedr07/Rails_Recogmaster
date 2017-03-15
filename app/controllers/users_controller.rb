require 'will_paginate/array'
class UsersController < ApplicationController
  before_filter :require_user, except: [:show, :received_recognitions, :sent_recognitions, :unsubscribe]
  before_filter :scoped_user, except: :index
  show_upgrade_banner only: [:index]

  filter_access_to :edit, :update, :hide_welcome, :has_read_new_feature, :upload_avatar, attribute_check: true

  skip_before_filter :ensure_correct_company, only: [:show, :received_recognitions, :sent_recognitions]

  layout "company_admin", only: :nominations
  
  def index
    @users = scoped_company.users.sort_by{|u| u.first_name.present? ? u.first_name.downcase : u.email.downcase}
    @users = @users.paginate(:page => params[:page], :per_page => 10)

    respond_to do |format|
      format.html
      format.json  { render json: @users }
    end
  end

  def coworkers
    @users = current_user.coworkers(params[:term])

    @users = @users[0..params[:limit].to_i-1] if params[:limit]

    respond_to do |format|
      format.html
      format.json  { render json: @users }
    end
  end

  def show
    # is with_permissions_to broken? - the rewrite using #select should be the same
    # @recognitions_sent = scoped_user.sent_recognitions.with_permissions_to(:show).limit(6)
    # @recognitions_received = scoped_user.received_recognitions.with_permissions_to(:show).limit(6)
    @recognitions_sent = scoped_user.sent_recognitions.select{|r| r.permitted_to?(:show)}
    @badge_counts = @user.badge_counts
    @redemptions = scoped_user.redemptions

    @achievements = scoped_user.received_recognitions.select { |recognition|
      Badge.find(recognition.badge_id).is_achievement == true
    }

    # @received_recognitions = scoped_user.received_recognitions.select{|r| r.permitted_to?(:show)}
    # @received_recognitions = @received_recognitions.paginate(:page => params[:page], :per_page => 10)

    render :action => "show"
  end

  def received_recognitions
    @received_recognitions = scoped_user.received_recognitions.select{|r| r.permitted_to?(:show)}
    @received_recognitions = @received_recognitions.paginate(:page => params[:page], :per_page => 10)
    render action: "received_recognitions", layout: false
  end

  def sent_recognitions
    @sent_recognitions = scoped_user.sent_recognitions.select{|r| r.permitted_to?(:show)}
    @sent_recognitions = @sent_recognitions.paginate(:page => params[:page], :per_page => 10)
    render action: "sent_recognitions", layout: false
  end

  def edit
    @support_email = SupportEmail.new
    @support_email.type = params[:type]
  end

  def update
    if @user.update_profile(params[:user])

      #HACK - updating the password logs us out(ie resets persistence_token), so just force login for now
      #       until we can figure a better way
      if current_user.id == @user.id && current_user.persistence_token != @user.persistence_token
        UserSession.login_as!(@user)
      end

      url = edit_user_path(@user, locale: (I18n.default_locale.to_s == @user.locale) ? nil : @user.locale)
      flash[:notice] = t("user_edit.success_profile_updated")
      respond_with @user, location: url
    else
      respond_with @user
    end
  end

  def update_slug
    @user.slug = params[:user][:slug]
    @user.save
    respond_with @user, location: user_path(@user, anchor: "email-signature")
  end

  def upload_avatar
    @user.update_avatar(params[:user][:avatar])
    respond_to do |format|
      format.html {
        render js: "window.location='"+edit_user_path(current_user)+"'"
      }
      format.js
    end
  end

  def hide_welcome
    @user.update_attribute(:has_read_welcome, true)
  end

  def has_read_new_feature
    @user.has_read_feature!(params[:feature])
    render nothing: true, status: 200
  end

  def invite
  end

  def send_invitations
    users_invited = []
    @user.delay(queue: 'priority').invite_from_yammer!(params[:user][:yammer_users])
    users_invited += @user.invite!(params[:user][:invitations])

    flash[:notice] = "Successfully sent invitations"
    # saved_users, error_users = users_invited.partition{|u| u.errors.empty?}
    # if saved_users.length > 0
    #   flash[:notice] = "Successfully sent invitations for #{saved_users.length + params[:user][:yammer_users].length} users".html_safe
    # end

    # if error_users.length > 0
    #   flash[:notice] = (flash[:notice].present? ? flash[:notice]+"<br />".html_safe : "".html_safe)
    #   flash[:notice] += "The following users could not be invited: <ul>".html_safe
    #   error_users.each do |u|
    #     flash[:notice] += "<li>#{u.email} - #{u.errors.full_messages.to_sentence}</li>".html_safe
    #   end
    #   flash[:notice] += "</ul>".html_safe
    # end
    redirect_to invite_users_path
  end

  def invite_from_yammer
    results = @user.invite_from_yammer!(params[:users].values)
    render json: results
  end

  def get_suggested_yammer_users
    @yammer_users_to_invite = current_user.cached_relevant_coworkers
    emails_to_reject = User.where(email: @yammer_users_to_invite.map(&:email)).map(&:email)
    yammer_ids_to_reject = User.where(yammer_id: @yammer_users_to_invite.map(&:yammer_id)).map(&:yammer_id)
    @yammer_users_to_invite.reject!{|u| yammer_ids_to_reject.include?(u.yammer_id.to_s) || emails_to_reject.include?(u.email)}

    render action: "get_suggested_yammer_users", layout: false
  end

  def get_relevant_yammer_coworkers
    @people = current_user.relevant_coworkers.shuffle[0..5]
    render action: "get_relevant_yammer_coworkers", layout: false
  end

  def promote_to_admin
    @user.roles << Role.company_admin
    render action: "update_roles"
  end

  def demote_from_admin
    @user.user_roles.where(role_id: Role.company_admin.id).destroy_all
    render action: "update_roles"
  end

  def promote_to_executive
    @user.roles << Role.executive
    render action: "update_executive_role"
  end

  def demote_from_executive
    @user.user_roles.where(role_id: Role.executive.id).destroy_all
    render action: "update_executive_role"
  end

  def destroy
    @user = User.where(network: current_user.network).find_by_slug(params[:id])
    if current_user == @user
      @user.delay.destroy
    else
      @user.delay.destroy
    end
  end

  def revoke_oauth_token
    @token = @user.oauth_access_tokens.find(id: params[:token_id])
    @token.destroy
  end

  def goto
    if params[:type].present?
      send("goto_"+params[:type].to_s.downcase)
    else
      goto_user
    end
  end

  def unsubscribe
    if @user = User.read_unsubscribe_token(params[:token])
      @user.unsubscribe!
    else
      render text: "Invalid Link"
    end
  end

  def nominations
    @user = User.find_by(id: params[:id])
    @nominations = Nomination.for_recipient(@user).where(badge_id: params[:badge_id])
    @nominations = @nominations.for_sender(current_user) unless current_user.company_admin?
  end

  protected

  def goto_user
    u = User.where(email: params[:email]).first
    if u
      redirect_to user_path(u, network: u.network)
    else
      redirect_to invite_users_path(network: current_user.network, email: params[:email])
    end
  end

  def goto_team
    team = Team.where(name: params[:name]).first
    redirect_to team_path(team)
  end

  def scoped_company
    @scoped_company ||= Company.where(domain: params[:network]).includes(:users).first
  end

  def scoped_user
    return @user if @user
    if params[:id]
      @user =  (id_is_int?(params[:id]) ?  User.find(params[:id]) : User.where(slug: params[:id], company_id: scoped_company.id).first)
      redirect_to root_path, notice: "There is no user that matches that description" and return unless @user
    else
      @user = current_user
    end
    return @user
  end

  def protect_access_to_current_user
    unless @user == current_user
      redirect_to user_path(@user)
      return false
    end
  end

  def id_is_int?(id)
    !!(id =~ /^[0-9]+$/)
  end
end
