# This is responsible for sending a personalized email blast
# to each user in a company that contains summary information
# for a particular time period
# CompanyReporter objects are sent in so that we can optimize
# that tabulation of stats for each company
require_dependency File.join(Rails.root, 'app/models/user')
class EmailBlast < ActionMailer::Base
  include IntervalHelper
  include MailHelper
  include EmailBlastHelper
  add_template_helper(RecognitionsHelper)
  add_template_helper(IntervalHelper)
  add_template_helper(EmailBlastHelper)
  
  default from: "Recognize <donotreply@recognizeapp.com>"
  layout false
  helper :mail

  def daily_blast(user, company_report)    
    @user = user
    @interval = company_report.interval
    @user_report = Report::User.new(@user, company_report.from, company_report.to)    
    @company_report = company_report    
    
    mail(to: @user.email, subject: "#{@user.company.name.humanize} daily recognitions", track_opens: true)
  end

  def weekly_blast(user, company_report, all_time_company_report)
    @user = user
    @interval = company_report.interval

    achievements(user)

    @user_report = Report::User.new(@user, company_report.from, company_report.to)    
    @company_report = company_report
    @all_time_company_report = all_time_company_report
        
    mail(to: @user.email, subject: "#{@user.company.name.humanize} weekly recognition update", track_opens: true)
  end
  
  def monthly_blast(user, company_report, all_time_company_report)
    @user = user
    @interval = company_report.interval

    achievements(user)

    @user_report = Report::User.new(@user, company_report.from, company_report.to)    
    @company_report = company_report    
    @all_time_company_report = all_time_company_report
    
    mail(to: @user.email, subject: "#{@user.company.name.humanize} monthly recognition update", track_opens: true)        
  end

  def yearly_blast(user, company_report, all_time_company_report)
    @user = user
    @interval = company_report.interval

    achievements(user)

    @user_report = Report::User.new(@user, company_report.from, company_report.to)    
    @company_report = company_report
    @all_time_company_report = all_time_company_report    
    
    mail(to: @user.email, subject: "#{@user.company.name.humanize}  #{@company_report.from.year} Year in Review", track_opens: true)
  end

  def achievements(user)
    if user.company.allow_achievements?
      @achievement_badges = user.company.company_badges.where(is_achievement: true)
      @achievement_badge_count = Badge.total_possible_achievement_count(user)
      @user_achievement_recognitions = user.received_recognitions.select { |recognition|
        Badge.find(recognition.badge_id).is_achievement == true
      }
    end
  end
  
  class Base
    @@users_table, @@settings_table, @@reminders_table, @@companies_table = ::User.arel_table, ::EmailSetting.arel_table, ::Reminder.arel_table, ::Company.arel_table
  
    INCLUDES = [:email_setting, :company, :user_roles]
        
    def initialize(opts={})
      @opts = opts
    end
    
    def interval_start
      interval.start(shift: -1)
    end

    def interval_end
      interval.end(shift: -1)
    end

    def blast_off!
      users = self.get_users
      set = users.group_by(&:company_id)

      set.each do |company_id, user_set|
        Rails.logger.debug " ------------------ Sending email blasts for company: #{company_id}"
        
        user_set.each do |user|
          
          Rails.logger.debug " ------------------ Sending email blasts for user: #{user.id}"
          begin
            send_blast(user) unless @opts[:dry_run]
          rescue Exception => e
            ExceptionNotifier.notify_exception(e, {data: {user: user}})
          end
        end
      end
      
      return users
    end

    def interval
      self.class.const_get("INTERVAL")
    end

    def all_time_company_report(company_id)
      @company_all_time_report ||= {}
      @company_all_time_report[company_id] ||= Report::Company.new(Company.find(company_id))
    end    

    def users_table;@@users_table;end
    def email_settings_table;@@settings_table;end
    def reminders_table;@@reminders_table;end
    def companies_table;@@companies_table;end
    
  end
  
  class Daily < Base
    INTERVAL = Interval.daily

    def company_report(company_id)
      @company_report ||= {}
      @company_report[company_id] ||= Report::Company.new(Company.find(company_id), interval_start, interval_end, interval: interval)
    end

    def get_users
      set = User.includes(*INCLUDES).
      
      # only companies that the global flag set to on
      where(companies: {allow_daily_emails: true}).

      # only send to active, verified users
      where(status: "active").
      where(users_table[:verified_at].eq(nil).not).

      # non personal account users
      where(users_table[:network].eq("users").not).
      
      # make sure they haven't fully subscribed
      where(email_settings: {global_unsubscribe: false}).
    
      # and they accept this particular notification
      where(email_settings: {daily_updates: true})
  
      return set      
    end

    def send_blast(user)
      report = self.company_report(user.company_id)
      EmailBlast.daily_blast(user, report).deliver if report.sent_recognitions.size > 0
    end    
  end

  class Weekly < Base
    INTERVAL = Interval.weekly

    def company_report(company_id)
      @company_report ||= {}
      @company_report[company_id] ||= Report::Company.new(Company.find(company_id), interval_start, interval_end, interval: interval)
    end
    
    def get_users
      set = User.includes(*INCLUDES).
      
      # only send to active, verified users
      where(status: "active").
      where(users_table[:verified_at].eq(nil).not).

      # non personal account users
      where(users_table[:network].eq("users").not).
      
      # make sure they haven't fully subscribed
      where(email_settings_table[:global_unsubscribe].eq(false)).
    
      # and they accept this particular notification
      where(email_settings_table[:weekly_updates].eq(true))
  
      return set

    end
  
    def send_blast(user)
      EmailBlast.weekly_blast(user, self.company_report(user.company_id), self.all_time_company_report(user.company_id)).deliver
    end
    
  end
  
  class Monthly < Base
    INTERVAL = Interval.monthly

    def company_report(company_id)
      @company_report ||= {}
      @company_report[company_id] ||= Report::Company.new(Company.find(company_id), interval_start, interval_end, interval: interval)
    end
    
    def get_users
      set = User.includes(*INCLUDES).
  
      # only send to active, verified users
      where(status: "active").
      where(users_table[:verified_at].eq(nil).not).

      # non personal account users
      where(users_table[:network].eq("users").not).

      # make sure they haven't fully subscribed
      where(email_settings_table[:global_unsubscribe].eq(false)).
    
      # and they accept this particular notification
      where(email_settings_table[:monthly_updates].eq(true))
    
      return set

    end
  
    def send_blast(user)
      EmailBlast.monthly_blast(user, self.company_report(user.company_id), self.all_time_company_report(user.company_id)).deliver
    end
    
  end

  class Yearly < Base
    INTERVAL = Interval.yearly

    def company_report(company_id)
      @company_report ||= {}
      @company_report[company_id] ||= Report::Company.new(Company.find(company_id), interval_start, interval_end, interval: interval)
    end
    
    def get_users
      set = User.includes(*INCLUDES).
  
      # only send to active, verified users
      where(status: "active").
      where(users_table[:verified_at].eq(nil).not).

      # non personal account users
      where(users_table[:network].eq("users").not).

      # make sure they haven't fully subscribed
      where(email_settings_table[:global_unsubscribe].eq(false)).
    
      # and they accept this particular notification
      where(email_settings_table[:monthly_updates].eq(true))
    
      return set

    end
  
    def send_blast(user)
      if self.company_report(user.company_id).sent_recognitions.size > 0
        EmailBlast.yearly_blast(user, self.company_report(user.company_id), self.all_time_company_report(user.company_id)).deliver
      end
    end
    
  end
end


