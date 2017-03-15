Rails.application.routes.draw do

  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)

  use_doorkeeper

  resources :inbound_emails, only: [:create]
  resources :chat_threads
  resources :chat_messages
  
  namespace :api do
    namespace :v1 do
      Seahorse::Model.add_all_routes(self, exclude_rpc_routes: true)
    end
  end

  mount Api::Base => '/api'
  
  root :to => "home#index", :constraints => LoggedInConstraint.new(:logged_out_route)
  root :to => "recognitions#index", :constraints => LoggedInConstraint.new(:logged_in_route), as: :authenticated_root

  get '/proxy.html' => "home#proxy"
  
  # MISC ROUTES
  resources :password_resets, except: [:destroy]
  resources :support_emails, only: [:new, :create]

  get '/contact', to: 'support_emails#new', as: :contact
  get '/sales', to: 'support_emails#sales', as: :contact_sales

  # FILE ROUTES
  get '/extensions/recognize.xpi', to: 'files#firefox_extension'

  #ADMIN ROUTES
  get '/admin', to: 'admin/index#index', as: :admin, via: :get

  namespace :admin do
    get 'emails' => 'index#emails'
    get 'email' => 'index#email'
    get 'signup_requests' => 'index#signup_requests'
    get 'login' => "index#login"
    get 'graph' => 'index#graph'
    get 'paid_engagement' => 'index#paid_engagement'
    get 'analytics' => "index#analytics"
    post 'refresh_analytics' => "index#refresh_analytics"
    get 'queue' => "index#queue"
    post 'purge_failed_queue' => "index#purge_failed_queue"
    
    get '/login_as', to: "index#login_as"
    post "/login_as", to: "index#login_as"
    post '/clear_queue_task/:task', to: "index#clear_queue_task", as: :clear_queue_task

    # match '/enable_custom_badges' => 'index#enable_custom_badges', via: [:post]
    # get 'manage'
    resources :companies, only: [:show, :create], constraints: {:id => /[^\/]+/}  do
      member do
        post "enable_custom_badges"
        post "enable_admin_dashboard"
        post "enable_achievements"
        post "enable_theme"
        patch :add_users
        post :add_directors
        delete :remove_directors
      end
      resources :subscriptions, except: [:index] do
        member do
          patch :cancel
        end
      end
    end

    resources :recognitions, only: [:index]

    resources :users, only: [:index] do 
      collection do 
        get :search
      end
    end

    resources :badges, only: [:index, :show]
    resources :subscriptions, only: [:index]
    resources :coupons do
      collection do
        post :sync
      end
    end
  end
  
  #SESSION ROUTES
  get '/ping', to: 'user_sessions#ping'
  get '/login', to: 'user_sessions#new'
  get '/login/signin', to: 'user_sessions#create', :as => :signin, :id => 'Sign In'
  get '/logout', to: 'user_sessions#destroy', :as => :logout
  resources :user_sessions
  
  #AUTHENTICATION ROUTES
  get '/auth/failure', to: 'authentications#failure', :as => :auth_failure
  get '/auth/:provider', to: 'authentications#create', :as => :remote_auth
  get '/auth/:provider/callback', to: 'authentications#create'

  # STATIC PATHS
  get "/getting-started", to: "home#getting_started", as: :getting_started
  get '/gamification', to: "home#gamification", as: :gamification
  get '/best-recognition-contest-2014', to: "home#contest", as: :contest
  get '/goto', to: "users#goto"
  get '/resend_verification_email', to: "password_resets#new", as: :resend_verification_email
  get '/home', to: "home#index", as: :marketing
  get '/sign-up', to: "home#sign_up", as: :sign_up
  get '/tour', to: "home#tour", as: :tour
  get '/engagement', to: "home#engagement", as: :engagement
  get '/analytics', to: "home#analytics", as: :analytics
  get '/customizations', to: "home#customizations", as: :customizations
  get '/pricing', to: "home#pricing", as: :pricing
  get '/features', to: "home#features", as: :features
  get '/about', to: "home#about", as: :about
  get '/yammer-integration', to: "home#extension", as: :extension
  get '/why-employee-recognition', to: "home#why", as: :why
  get '/case-study',to: "home#case_study", as: :case_study
  get '/privacy', to: "home#privacy_policy", as: :privacy_policy
  get '/terms', to: "home#terms_of_use", as: :terms_of_use
  get '/maintenance', to: "home#maintenance", :as => :maintenance
  get '/coworkers', to: "users#coworkers", as: :coworkers
  get '/help', to: redirect("http://recognize.zendesk.com"), :as => :help
  get '/upgrade/(:code)', to: "home#upgrade", as: :upgrade_promotion
  get "/distributed-workforce-infographic", to: "home#distributed_workforce_infographic", as: :distributed_workforce_infographic
  get "/year-in-review", to: "mailers#year_in_review"  
  get "/unsubscribe/:token", to: "users#unsubscribe", as: :unsubscribe
  get "/rewards", to: "home#rewards", as: :rewards
  get "/employee-recognition-awards", to: "home#awards", as: "awards"
  get "/office-365", to: "home#office365", as: :office365
  get "/mobile-employee-recognition", to: "home#mobile", as: :mobile
  get "/idp_check", to: "saml#idp_check"

  # COMPANY SCOPED ROUTES
  scope "/:network", constraints: {:network => /[^\/]+/} do
    constraints DomainConstraint.new do
      get "/" => "recognitions#index", as: "stream"
      get '/welcome', to: 'welcome#show', as: "welcome"
      put '/welcome/save_user_count', to: 'welcome#save_user_count', as: :save_user_count
  
      resources :subscriptions
      get '/upgrade', to: "subscriptions#new", as: :upgrade  
      get '/upgrade/(:code)', to: "subscriptions#new"

      # CORE RESOURCE ROUTES
      resource :company, only: [:show, :update] do
        resources :badges, only: [:new, :create, :destroy, :index, :show] do
          collection do
            patch :update_all
          end
        end

        get :accounts
        get :check_list
        get :reports
        get :recognitions
        post :update_privacy
        post :update_settings
        put :add_users
        post :resend_invitation_email
        patch :update_point_values
        patch :update_kiosk_mode_key
        patch :update_recognition_limits

        resources :rewards
        resource :saml_configuration

      end

      scope :company, module: :company_admin, as: :company_admin do
        resources :roles
        resources :nominations, only: [:index] do
          member do
            get :votes
            post :award
          end
        end
        resources :campaigns, only: [:show] do
          member do 
            post :archive
          end
        end
      end

      resources :departments
      resources :hall_of_fame
      resource :accounts, only: [:edit, :update]
      resources :redemptions, path: 'rewards'

      resources :teams do
        scope module: 'team_management' do
          resource :members, only: [:edit, :update]
          resource :managers, only: [:edit, :update]          
        end
        member do 
          get :nominations          
        end
      end

      resource :team_assignment, only: [:create, :destroy]

      resource :anniversaries , only: [] do
        collection do
          get :change_roles
          get :assign_role
          get :unassign_role
          get :add_user
          get :remove_user
        end
      end

      resources :email_settings
      # resources :invite

      #REPORTS ROUTES
      get "/reports", to: "reports#index", as: :reports
      get "/reports/users", to: "reports#users", as: :user_reports
      get "/reports/teams", to: "reports#teams", as: :team_reports
      get "/reports/top_users", to: "reports#top_users", as: :top_users_reports
      # get "/reports/:start_date", to: "reports#previous", as: :previous_report
      # get "/reports/badge/:badge_id/:start_date", to: "reports#badge_leaderboard", as: :badge_leaderboard

      # RECOGNITION ROUTES
      # skip show since that needs to be accessed unscoped
      # NOTE: must be above users to avoid dynamic matching
      resources :recognitions, except: [:show, :update, :destroy, :badge] do
        collection do
          post :recognize_instantly
          get :new_chromeless
        end
        member do
          patch :update, as: "update"
          delete :destroy, as: "destroy"
          put :toggle_privacy
        end
        resources :approvals, controller: "recognition_approvals", only: [:create, :destroy]
      end

      resource :identity_provider, path: "idp", only: [:show]
      resources :nominations, only: [:index, :new, :create] do
        collection do
          get :new_chromeless
        end
      end

      # USER ROUTES
      get "/users", to: "users#index", as: "users"
      resources :users, path: "", path_names: {new: "users/new"}, except:[:index, :create] do
        collection do
          get :invite
          get :get_suggested_yammer_users
          get :get_relevant_yammer_coworkers
          patch :send_invitations      
          patch :invite_from_yammer
        end
        member do
          patch :promote_to_admin
          patch :demote_from_admin
          patch :promote_to_executive
          patch :demote_from_executive
          patch :hide_welcome
          put :has_read_new_feature
          patch :upload_avatar
          patch :update_slug
          patch :revoke_oauth_token
          get :received_recognitions
          get :sent_recognitions
          get :nominations
        end

        # USER RECOGNITION ROUTES
        resources :recognitions, only: [] do
          collection do
            get :sent
            get :received
          end
        end

        resource :company_roles, only: [:create, :destroy], controller: :user_company_roles
      end

      resources :saml, only: :index do
        collection do
          get :sso
          post :acs
          get :metadata
          get :logout
          put :complete
        end
      end      

    end # end constraint
  end # end :domain scope

  # Allow showing a recognition to be unscoped 
  # since param is a guid
  # NOTE: this takes precedence over scoped routes
  #       and thus must be above
  get '/recognitions/:id/share/:provider', to: "recognitions#share", :as => "share_recognition"  
  resources :recognitions, only: [] do
    resources :comments
    member do
      # need to say: recognition_path(@recognition),
      # takes it away from above put/delete resource route
      get :show, as: "" 
      get :certificate, as: 'certificate'

    end
  end
  
  # SIGNUP ROUTES
  resources :signups, path: :signup do
    collection do
      put :full_name
      put :password
      get :confirm_email
      get :requested
      get :recognize
      post :personal_interest
    end
    member do
      get :verify
    end
  end

  resource :account_chooser, controller: :account_chooser, only: [:show, :update]

  # match "/:network/*path", to: "application#routing_error",  constraints: lambda {|request| request.params[:network] != 'uploads'}, format: false
    # match "/:network/*path", to: "application#routing_error", format: false
  # match "*path", to: "application#routing_error"

  get 'robots.txt' => "home#robots"

  get "/:network", to: "application#routing_error", constraints: {:network => /[^\/]+/} , format: false
  get "/:network*path", to: "application#routing_error", constraints: {:network => /[^\/]+/} , format: false


  # match "/:network*path", to: "application#routing_error"
end
