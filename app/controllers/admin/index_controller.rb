class Admin::IndexController < Admin::BaseController
  skip_before_filter :check_bg_queue, only: [:graph]

  def index

    setup_data!

    @limit = params[:limit].present? ? params[:limit].to_i : 25

    @sorted_companies = @companies
    @company_auth_map = Authentication.where(provider: "yammer").includes(:user).all.inject({}){|hash, a| hash[a.user.company_id] ||= true; hash }
    
    
    @spacer = ' -- '

    sort_data!
  end
  
  def emails
    @emails = EmailLog.order("date desc").paginate(page: params[:page], per_page: 20)
  end
  def email
    @email = EmailLog.find(params[:id])
  end

  def signup_requests
    @requests = SignupRequest.scoped
  end

  def login
  end

  def login_as
    if params[:id].present?
      @user = User.find(params[:id])
    else
      @user = User.where(email: params[:email]).first
    end

    if @user.present?

      if @user.id == current_user.acting_as_superuser
        session.delete(:superuser)
        redirect_url = admin_path
      else
        session[:superuser] = current_user.id
        redirect_url = root_path
      end

      user_session = UserSession.new(@user, true)
      user_session.save!
      redirect_to redirect_url

    else
      flash[:error] = "There is no user with that email address" 
      render "login"
    end
  end
  
  def analytics
    @data = Company.analytics_data
    @company_count = Company.count
    @activated_companies = @data.activated_companies
    @report = DataReporter::Report.new(Company.analytics_data)
  end
  
  def refresh_analytics
    Company.analytics_data.refresh!
    @data = Company.analytics_data
    redirect_to admin_analytics_path
  end

  def queue
    @jobs = Delayed::Job.where("failed_at is null").order("created_at asc")
    @jobs = @jobs.where(queue: params[:queue]) if params[:queue].present?
    @counts = Delayed::Job.where("failed_at is null").order("created_at asc").group_by(&:queue).map{|q,j|  [q, j.length]}
    @failed_jobs = Delayed::Job.where("failed_at is NOT null").order("created_at desc")
  end

  ALLOWABLE_QUEUE_TASKS = [:refresh_cached_yammer_groups!, :prime_caches!]
  def clear_queue_task
    task = params[:task].to_sym
    if ALLOWABLE_QUEUE_TASKS.include?(task)
      Delayed::Job.where("handler like '%method_name: :#{task}%'").delete_all
      flash[:notice] = "Removed tasks for #{task}"
    end

    redirect_to admin_queue_path
    
  end
  
  def purge_failed_queue
    @failed_jobs = Delayed::Job.where("failed_at is NOT null").limit(500).order("created_at asc")
    @failed_jobs.destroy_all
    flash[:notice] = "Successfully purged failed jobs"
    render js: "window.location='#{admin_queue_path}'"
  end

  def graph
    setup_data!
    @graph_data = {
        companies: GraphData.load(@companies, :weekly),
        recognitions: GraphData.load(@recognitions, :weekly),
        users: GraphData.load(@users, :weekly),
        approvals: GraphData.load(@recognition_approvals, :weekly)
    }
    render action: "graph", layout: false
  end

  def paid_engagement
    @companies = Subscription.where.not(quantity: nil).map(&:company)
    company_ids = @companies.map(&:id)
    @recognitions = Recognition.where(sender_company_id: company_ids).where("created_at >= ? AND created_at <= ?", 3.months.ago, Time.now).group_by{|r| r.sender_company.domain}
    @graph_data = @recognitions.inject({}){|hash, (domain, recognitions)| hash[domain] = GraphData.load(recognitions, :weekly);hash}
  end

  private
  def setup_data!
    @recognize = Company.where(domain: "recognizeapp.com").first

    if params[:network].present?
      @companies = Company.where("companies.domain  like '%#{params[:network]}%' ")
      company_ids = @companies.map(&:id)
      @users = User.unscope(:joins).where("users.company_id IN (?)", company_ids)
      @recognitions = Recognition.where(sender_company_id: company_ids)
      recognition_ids = @recognitions.map(&:id)
      @top_badges = Badge.top_badges_for_companies(company_ids, recognition_ids: recognition_ids)
      @recognition_approvals = RecognitionApproval.joins(:recognition).where("recognition_approvals.created_at > ?", Time.parse("Feb 1, 2013")).where("recognitions.id IN (?)", recognition_ids)
    else
      @companies = Company.where("companies.id <> #{@recognize.id}").order("companies.created_at desc")
      @users = User.unscope(:joins).where("company_id <> #{@recognize.id}")
      @recognitions = Recognition.where("(recognitions.sender_company_id <> #{@recognize.id}) AND badge_id NOT IN (?)", Badge.system_badge_ids)
      @top_badges = Badge.top_badges
      @recognition_approvals = RecognitionApproval.where("created_at > ?", Time.parse("Feb 1, 2013"))

    end
  end

  def sort_data!
    if params[:order_by]
      @sorted_companies = case params[:order_by]
        when "last_recognition"
          @sorted_companies.sort_by{|c| c.last_recognition_sent_at || Time.at(0)}.reverse!
        when "last_user"
          @sorted_companies.sort_by{|c| c.last_user_created_at || Time.at(0)}.reverse!
        when "most_users"
          @sorted_companies.sort!{|c1, c2| c2.users_count <=> c1.users_count}
        when "most_recognitions_sent"
          @sorted_companies.sort!{|c1, c2| c2.sent_user_recognitions_count <=> c1.sent_user_recognitions_count}
        when "most_recognitions_received"
          @sorted_companies.sort!{|c1, c2| c2.received_user_recognitions_count <=> c1.received_user_recognitions_count}
        when "yammer"
          res = @sorted_companies.sort!{|c1, c2|
            c1yammer = @company_auth_map[c1.id].present?
            c2yammer = @company_auth_map[c2.id].present?
            if (c1yammer == c2yammer)
              c2.id <=> c1.id
            elsif c1yammer and !c2yammer
              -1
            elsif !c1yammer and c2yammer
              1
            end
          }
      end
    else
      @sorted_companies = @sorted_companies.limit(@limit)
    end
  end
end