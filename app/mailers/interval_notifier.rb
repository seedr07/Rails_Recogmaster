# IntervalNotifier::Manager.notify_all!(Interval::MONTHLY, :monthly, "companies.domain like 'recognizeapp.com'")
require 'chronic'
class IntervalNotifier < ActionMailer::Base
  include IntervalHelper
  include MailHelper
  add_template_helper(IntervalHelper)
  add_template_helper(MailHelper)

  layout "interval_mailer"
  default from: "Recognize <donotreply@recognizeapp.com>"

  def self.run_scheduler
    time = Time.now
    first_tuesday_of_month = Chronic.parse("First Tuesday of this #{time.strftime('%B')}")

    # Tuesdays
    IntervalNotifier.notify_weekly! if time.wday == 2

    # First tuesday of month
    IntervalNotifier.notify_monthly! if time.to_date == first_tuesday_of_month.to_date

    # First tuesday after start of quarter
    # (ie its a month of the start of quarter, and its the first tuesday of month)
    IntervalNotifier.notify_quarterly! if (time.beginning_of_quarter.month == time.month && time.to_date == first_tuesday_of_month.to_date)

  end

  def self.notify_weekly!
    Manager.notify_all!(Interval::WEEKLY, :weekly)
  end

  def self.notify_monthly!
    Manager.notify_all!(Interval::MONTHLY, :monthly)
  end

  def self.notify_quarterly!
    Manager.notify_all!(Interval::QUARTERLY, :quarterly)
  end

  def self.notify_yearly!
    Manager.notify_all!(Interval::YEARLY, :yearly)
  end

  def weekly(user, winning_users, winning_teams)
    @interval_label = "last week"
    setup(user, winning_users, winning_teams)
    if user.email_setting.interval_winner_notifications
      mail(to: user.email, subject: "Recognition winners for #{@interval_label}", track_opens: true)
    end
  end

  def monthly(user, winning_users, winning_teams)
    @interval_label = "last month"
    setup(user, winning_users, winning_teams)
    if user.email_setting.interval_winner_notifications
      mail(to: user.email, subject: "Recognition winners for #{@interval_label}", track_opens: true)
    end
  end

  def quarterly(user, winning_users, winning_teams)
    @interval_label = "last quarter"
    setup(user, winning_users, winning_teams)
    if user.email_setting.interval_winner_notifications
      mail(to: user.email, subject: "Recognition winners for #{@interval_label}", track_opens: true)
    end
  end

  def yearly(user, winning_users, winning_teams)
    @interval_label = "last year"
    setup(user, winning_users, winning_teams)
    if user.email_setting.interval_winner_notifications
      mail(to: user.email, subject: "Recognition winners for #{@interval_label}", track_opens: true)
    end
  end

  private
  def setup(user, winning_users, winning_teams)
    @user = user
    @winning_users = User.where(id: winning_users).map{|u| {user: u}}
    @winning_teams = Team.where(id: winning_teams).map{|t| OpenStruct.new(team: t)}
  end

  class Manager
    attr_reader :interval, :mail_method, :condition

    def self.notify_all!(interval, mail_method, condition=nil)
      new(interval, mail_method, condition).notify_all!
    end

    def initialize(interval, mail_method, condition)
      @interval = Interval.new(interval)
      @mail_method = mail_method
      @condition = condition || "domain like 'a%'"
    end

    def notify_all!
      users do |user, winning_users, winning_teams|
        IntervalNotifier.delay.send(mail_method, user, winning_users.values.map{|u| u[:id]}, winning_teams.map{|t| t.team.id})
      end
    end

    private

    def users
      companies.each do |company|
        report = Report::Company.new(company, interval_start, interval_end)
        next unless report.received_recognitions.size > 1
        winning_users = report.first_place_leaders(:points)
        winning_teams =report.first_place_teams(:total_points)
        users = company.users.joins(:email_setting).where(status: "active", email_settings: {interval_winner_notifications: true, global_unsubscribe: false})
        users.each do |user|
          yield(user, winning_users, winning_teams)
        end
      end
    end

    def companies
      @companies ||= get_companies
    end

    def get_companies
      set = Company.where(reset_interval: interval.to_i, allow_interval_winner_notifications: true)
        .where.not(domain: "users")
      set = set.send("where", condition) unless condition == :skip
      return set
    end

    def interval_start
      interval.start(shift: -1)
    end

    def interval_end
      interval.end(shift: -1)
    end

    def interval
      Interval.new(@interval)
    end
  end # Manager


end