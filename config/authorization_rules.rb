authorization do
  role :guest do
    has_permission_on :help, to: [:index]
    has_permission_on :home, to: [:index, :tour, :contact, :pricing,
                                  :why, :privacy_policy, :terms_of_use,
                                  :maintenance, :upgrade, :extension,
                                  :distributed_workforce_infographic, :about,
                                  :case_study, :robots, :proxy, :sign_up,
                                  :customizations, :contest, :analytics, :engagement,
                                  :gamification, :getting_started, :features, :rewards,
                                  :awards, :office365, :mobile]

    has_permission_on :user_sessions, to: [:new, :create, :destroy, :ping]
    has_permission_on :authentications, to: [:create, :oauth_failure, :failure]
    has_permission_on :password_resets, to: [:index, :new, :create, :edit, :update]
    has_permission_on :recognitions, to: [:index]
    has_permission_on :recognitions, to: [:show, :share] do
      if_attribute :is_public => is{true}
      if_attribute :allow_guest_access => is{true}
    end

    has_permission_on :recognitions, to: [:certificate] do
      if_attribute :is_public => is{true}, :has_proper_recipients_for_certificate? => is{true}
      if_attribute :allow_guest_access => is{true}, :has_proper_recipients_for_certificate? => is{true}
    end

    has_permission_on :signups, to: [:create, :full_name, :password, :confirm_email, :verify, :requested, :recognize, :personal_interest]
    has_permission_on :support_emails, to: [:new, :create, :sales]
    has_permission_on :users, to: [:show, :received_recognitions, :sent_recognitions, :unsubscribe]
    has_permission_on :application, to: [:routing_error]
    has_permission_on :files, to: [:firefox_extension]

    has_permission_on :chat_messages, to: [:new, :create]
    has_permission_on :chat_threads, to: [:new, :create]
    has_permission_on :inbound_emails, to: [:create]
    has_permission_on :identity_providers, to: [:show]
    has_permission_on :saml, to: [:index, :sso, :acs, :metadata, :logout, :complete, :idp_check]
    has_permission_on :account_chooser, to: [:show, :update]
  end

  role :employee do
    includes :guest

    has_permission_on :hall_of_fame, to: [:index] do
      if_attribute :can_view_hall_of_fame? => is{true}
    end

    has_permission_on :redemptions, to: [:restful_actions] do
      if_attribute :can_view_rewards? => is{true}
    end

    has_permission_on :badges, to: [:index, :show]
    has_permission_on :welcome, to: [:show, :save_user_count]
    has_permission_on :recognitions, to: [:index, :new, :new_chromeless, :create, :sent, :received, :share, :recognize_instantly]
    has_permission_on :recognitions, to: [:show] do
      if_attribute :participant_company_ids => contains{user.company_id}
    end
    has_permission_on :recognitions, to: [:certificate] do
      if_attribute :participant_company_ids => contains{user.company_id}, :has_proper_recipients_for_certificate? => is{true}
    end
    has_permission_on :recognitions, to: [:edit, :update] do
      if_attribute :sender_id => is{user.id}
    end
    has_permission_on :recognitions, to: [:destroy, :toggle_privacy] do
      # if_attribute :sender_id => is{user.id}
      if_attribute :participant_ids => contains{user.id}
    end
    has_permission_on :recognition_approvals, to: [:create, :destroy] do
    end
    has_permission_on :users, to: [:index, :show, :invite, :send_invitations, :invite_from_yammer,
      :coworkers, :get_suggested_yammer_users, :get_relevant_yammer_coworkers, :goto]
    has_permission_on :users, to: [:edit, :update, :hide_welcome, :has_read_new_feature, :upload_avatar, :update_slug, :revoke_oauth_token, :destroy] do
      if_attribute id: is{user.id}, network: is{user.network}
    end
    has_permission_on :reports, to: [:index, :users, :teams, :top_users]
    has_permission_on :teams, to: [:show, :new, :create]
    has_permission_on :teams, to: [:restful_actions] do
      if_attribute :managers => contains { user }
    end
    has_permission_on :team_assignments, to: :create
    has_permission_on :team_assignments, to: :destroy

    # this is authorization rules for base class and covers all subclasses
    has_permission_on :team_management_team, to: [:edit, :update] do
      if_attribute :managers => contains { user }
    end

    has_permission_on :comments, to: [:restful_actions] do
      if_attribute commenter_id: is{user.id}
    end
    has_permission_on :admin_index, to: [:login_as] do
      if_attribute acting_as_superuser: is{true}
    end
    has_permission_on :subscriptions, to: [:new, :create]
    has_permission_on :subscriptions, to: [:show, :edit, :update, :destroy] do
      if_attribute user_id: is{user.id}
      if_attribute status: is{Subscription::PENDING}
    end

    has_permission_on :mailers, to: [:show, :year_in_review]
    has_permission_on :companies, to: [:show, :check_list] do
      if_attribute allow_admin_dashboard: is{false}
    end

    has_permission_on :nominations, to: [:index, :new, :create, :new_chromeless]
  end

  role :company_admin do
    includes :employee

    has_permission_on :users, to: [:promote_to_admin, :demote_from_admin, :promote_to_executive, :demote_from_executive, :destroy, :nominations]
    has_permission_on :users, to: [:edit, :update, :hide_welcome, :has_read_new_feature, :upload_avatar, :update_slug, :revoke_oauth_token, :destroy] do
      if_attribute network: is_in{ user.company.family.map(&:domain) }
    end
    has_permission_on :recognitions, to: [:edit, :destroy, :update] do
      if_attribute sender_company_id: is{user.company_id}
    end
    has_permission_on :companies, to: [:show, :update, :recognitions, :update_privacy, :accounts, :add_users, :update_settings, :reports, :resend_invitation_email, :update_point_values, :update_recognition_limits, :update_kiosk_mode_key] do
      if_attribute allow_admin_dashboard: is{true}
    end
    has_permission_on :badges, to: [:new, :create, :destroy, :update_all]
    has_permission_on :subscriptions, to: [:show, :edit, :update, :destroy] do
      if_attribute company_id: is{user.company_id}, status: is_not{Subscription::CANCELED}
    end

    has_permission_on :teams, to: [:restful_actions, :nominations]
    has_permission_on :team_management_team, to: [:edit, :update]
    has_permission_on :anniversaries, to: [:assign_role, :unassign_role, :add_user, :remove_user, :change_roles]
    has_permission_on :accounts, to: [:edit, :update]
    has_permission_on :rewards, to: [:restful_actions]
    has_permission_on :company_admin_roles, to: [:restful_actions]
    has_permission_on :user_company_roles, to: [:create, :destroy]
    has_permission_on :saml_configurations, to: [:update]
    has_permission_on :company_admin_nominations, to: [:index, :award, :votes] do
      # TODO: add permissions for roles here
    end
    has_permission_on :company_admin_campaigns, to: [:show, :archive] do
      # TODO: add permissions for roles here
    end

  end

  role  :director do
    includes :company_admin
    has_permission_on :departments, to: [:restful_actions]
  end

  role :admin do
    includes :company_admin
    has_permission_on :admin_index, to: [:index, :emails, :email, :signup_requests, :login, :login_as, :analytics, :graph, :paid_engagement, :refresh_analytics, :queue, :purge_failed_queue, :clear_queue_task]
    has_permission_on :admin_companies, to: [:show,:create, :enable_custom_badges, :enable_admin_dashboard, :enable_achievements, :add_users, :enable_theme, :add_directors, :remove_directors]
    has_permission_on :admin_recognitions, to: [:index]
    has_permission_on :admin_users, to: [:index, :search]
    has_permission_on :admin_subscriptions, to: [:index, :show, :create, :update, :new, :edit, :cancel]
    has_permission_on :admin_coupons, to: [:restful_actions, :sync]
    has_permission_on :recognitions, to: :restful_actions
    has_permission_on :badges, to: :restful_actions
    has_permission_on :companies, to: :restful_actions
    has_permission_on :teams, to: :restful_actions
    has_permission_on :tags, to: :restful_actions
    has_permission_on :authorization_rules, to: [:index, :graph, :change, :suggest_change, :read]
    has_permission_on :authorization_usages, to: [:index, :read]

    has_permission_on :chat_messages, to: [:new, :create, :index, :show]
    has_permission_on :chat_threads, to: [:new, :create, :index, :show]
  end
end

privileges do

  privilege :restful_actions do
    includes :index, :show, :new, :create, :edit, :update, :destroy
  end
end

