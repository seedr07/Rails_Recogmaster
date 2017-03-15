# This class is mostly responsible for
# sending automated email reminders
# but also is responsible for handling
# automated tasks like disabling accounts
# that have not been verified
require File.join(Rails.root, 'spec/support/reminder_simulator')
class Reminder < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :user
  validates :user_id, presence: true

  INCLUDES = [:reminder, :email_setting, :company, :user_roles]
    
  class Process
    # map sets of users to their reminder notifier method
    MAP = {
      users_who_have_not_sent_invitations_nor_recognitions: :no_invites_and_no_recognitions_reminder,
      users_who_have_invited_but_not_recognized_anyone: :invited_but_no_recognitions_reminder,
      users_who_are_inactive: :inactive_user_reminder,
      users_who_have_not_verified_and_need_to_be_warned_first_time: :has_not_verified_first_warning,
      users_who_have_not_verified_and_need_to_be_warned_second_time: :has_not_verified_second_warning,
      users_who_have_not_verified_and_need_to_be_warned_third_time: :has_not_verified_third_warning,
      users_who_have_not_verified_and_need_to_be_disabled: :has_not_verified_and_is_now_disabled
    }
    
    def self.tomorrow_simulation(days=30)
      Rails.logger.info " ------------- #{Time.now.to_formatted_s(:db)} - Beginning Reminder#tomorrow_simulation"
      ReminderSimulator.run(days, dry_run: true, email: true)
      Rails.logger.info " ------------- #{Time.now.to_formatted_s(:db)} - Completed Reminder#tomorrow_simulation"
    end
    
    # wrapper called by cron which just pushes out to DelayedJob
    def self.daily
      # unless Recognize::Application.config.host == "recognizeapp.com"
      #   puts "skipping because this is not production server"
      #   return
      # end

      Rails.logger.info "#{Time.now.to_formatted_s(:db)} - Beginning Reminder#daily"
      # gather results here is mainly for simulation
      # because in real life, we'd get back the delayed job object
      process = Process.new
      
      # every day cron will run, and here we decide, 
      # is a daily, weekly, or monthly run
      t = Time.now
      if t.monday? and t.day.between?(1, 7)
        results = process.run!(as: :monthly)
      elsif t.monday?
        results = process.run!(as: :weekly)        
      elsif t.wday.between?(1,5) # only run during the week
        results = process.run!(as: :daily)
      end
      Rails.logger.info " ------------- #{Time.now.to_formatted_s(:db)} - Completed Reminder#daily"
      return results
    end

    def initialize(opts={})
      @opts = opts
    end
    

    # We never want a "daily", "weekly", or "monthly" run to overlap
    # seeing as however every 7th day is on a weekly run, 30th day
    # is on a monthly run, and every 4th weekly run could also be on the 
    # monthly run
    # so i'm building that protection here in the Process class, since this
    # is the interface to the outside world
    def run!(opts={})
      results = []
      
      case opts[:as]

      when :weekly
        results << [:weekly_blast, Reminder.send_weekly_blast]

      when :monthly
        results << [:monthly_blast, Reminder.send_montly_blast]

      # else daily
      when :daily
        results << [:daily_blast, Reminder.send_daily_blast]
        # results << self.remind_all(:users_who_have_not_sent_invitations_nor_recognitions)
        # results << self.remind_all(:users_who_have_invited_but_not_recognized_anyone)
        # results << self.remind_all(:users_who_are_inactive)
        # results << self.remind_all(:users_who_have_not_verified_and_need_to_be_warned_first_time)
        # results << self.remind_all(:users_who_have_not_verified_and_need_to_be_warned_second_time)
        # results << self.remind_all(:users_who_have_not_verified_and_need_to_be_warned_third_time)
        # results << self.handle(:users_who_have_not_verified_and_need_to_be_disabled, with: :disable_unverified_users)
        # results << self.handle(:companies_to_be_destroyed, with: :destroy_companies)

      else
        raise "Unsupported frequency"
      end

      return results
    end
        
    def remind_all(who)
      set = Reminder.send(who)
      notifier_method = MAP[who]
      set.each do |user|
        self.remind(user, notifier_method)
      end
      return [notifier_method, set]      
    end

    def remind(user, notifier_method)
      ReminderNotifier.delay.send(notifier_method, user) unless dry_run?
      Reminder.mark_sent!(user, notifier_method)
    end

    def handle(who, opts={})
      method = opts[:with]
      set = Reminder.send(who)
    
      Reminder.send(method, set)

      return [method, set]
    end

    def dry_run?
      @opts[:dry_run]
    end
  end

  def self.send_daily_blast(opts={})
    daily_blast = EmailBlast::Daily.new(opts)
    daily_blast.blast_off!    
  end

  def self.send_weekly_blast(opts={})
    weekly_blast = EmailBlast::Weekly.new(opts)
    weekly_blast.blast_off!    
  end
  
  def self.send_montly_blast(opts={})
    monthly_blast = EmailBlast::Monthly.new(opts)
    monthly_blast.blast_off!
  end
    
  def self.users_who_have_not_sent_invitations_nor_recognitions
    threshold = 72.hours.ago
    
    users, reminders, email_settings = User.arel_table, Reminder.arel_table, EmailSetting.arel_table
    
    set = User.includes(*INCLUDES).references(*INCLUDES)
    
      #get users who have not sent invitations
      where(invited_users_count: 0).

      # AND get users who ALSO have not sent recognitions
      where(sent_recognitions_count: 0).

      # AND has verified their email
      where(users[:verified_at].eq(nil).not).
      
      # AND have not gotten either reminder email
      where(reminders[:no_invites_and_no_recognitions_reminder_sent_at].eq(nil)).
      where(reminders[:invited_but_no_recognitions_reminder_sent_at].eq(nil)).
      
      # AND 
      # EITHER
      # for users who have signed up(not invited) 
      # its been 72 hours since they've been created
      where(
        users[:invited_by_id].eq(nil).and(users[:created_at].lt(threshold)).or(
        
        # OR
        # for users who have been invited
        # and its been 72 hours since they've logged in
        users[:invited_by_id].eq(nil).not.and(
          users[:last_login_at].eq(nil).not.and(users[:last_login_at].lt(threshold)))
      )).
      
      # AND haven't unsubscribed from all
      where(email_settings[:global_unsubscribe].eq(false)).

      # AND want to receive activity reminders
      where(email_settings[:activity_reminders].eq(true))
      
    return set
  end
  
  def self.users_who_have_invited_but_not_recognized_anyone
    threshold = 72.hours.ago

    users, reminders, email_settings = User.arel_table, Reminder.arel_table, EmailSetting.arel_table
    
    set = User.includes(*INCLUDES).references(*INCLUDES).where(
      
      # get users who have invited people
      users[:invited_users_count].gt(0).and(
      
      # AND not recognized anyone
      users[:sent_recognitions_count].eq(0)).and(

      # AND has verified their email
      users[:verified_at].eq(nil).not).and(
            
      # AND received neither alert
      reminders[:no_invites_and_no_recognitions_reminder_sent_at].eq(nil)).and(
      reminders[:invited_but_no_recognitions_reminder_sent_at].eq(nil)).and(

      # AND 
      # for either: non-invited users(signups) its been 72 hours since they've been created
      users[:invited_by_id].eq(nil).and(users[:created_at].lt(threshold)).or(

      # OR for invited users its been 72 hours since they've logged in
      users[:invited_by_id].eq(nil).not.and(
        users[:last_login_at].eq(nil).not.and(users[:last_login_at].lt(threshold)))      
      ))).
      
      # AND haven't unsubscribed from all
      where(email_settings[:global_unsubscribe].eq(false)).

      # AND want to receive activity reminders
      where(email_settings[:activity_reminders].eq(true))
      
    
    
    return set
  end
  
  def self.users_who_are_inactive
    threshold = 3.weeks.ago
    
    users, reminders, email_settings = User.arel_table, Reminder.arel_table, EmailSetting.arel_table
    
    set = User.includes(*INCLUDES).references(*INCLUDES).where(
    
    # find users who have not been alerted
      (reminders[:inactive_user_reminder_sent_at].eq(nil).or(
      
      # OR they've been alerted more than 3 weeks ago
      reminders[:inactive_user_reminder_sent_at].lt(threshold)
      ))
    ).where(
    
      # AND its been 3 weeks since their last login
      users[:last_login_at].lt(threshold)
    
    ).

    # AND have sent at least one recognition
    where(users[:sent_recognitions_count].gt(0)).

    # AND has verified their email
    where(users[:verified_at].eq(nil).not).
    
    # AND haven't unsubscribed from all
    where(email_settings[:global_unsubscribe].eq(false)).

    # AND want to receive activity reminders
    where(email_settings[:activity_reminders].eq(true))
    
    return set
  end

  def self.users_who_have_not_verified_and_need_to_be_warned_first_time; self.users_who_have_not_verified_and_need_to_be_warned(:first); end
  def self.users_who_have_not_verified_and_need_to_be_warned_second_time; self.users_who_have_not_verified_and_need_to_be_warned(:second); end
  def self.users_who_have_not_verified_and_need_to_be_warned_third_time; self.users_who_have_not_verified_and_need_to_be_warned(:third); end
  
  # this is a warning to the first user who
  # signed up that they must verified their email
  def self.users_who_have_not_verified_and_need_to_be_warned(warning_ordinal)
    threshold = 1.week.ago
    
    users, reminders, companies, email_settings = User.arel_table, Reminder.arel_table, Company.arel_table, EmailSetting.arel_table

    set = User.includes(*INCLUDES).references(*INCLUDES)
    
    set = case warning_ordinal
    when :first
      set.where(reminders[:has_not_verified_first_warning_sent_at].eq(nil)).
      where(reminders[:has_not_verified_second_warning_sent_at].eq(nil)).
      where(reminders[:has_not_verified_third_warning_sent_at].eq(nil)).
      # its been 1.week since signup
      where(users[:created_at].lt(threshold))
    when :second
      set.where(reminders[:has_not_verified_first_warning_sent_at].eq(nil).not).
      where(reminders[:has_not_verified_second_warning_sent_at].eq(nil)).
      where(reminders[:has_not_verified_third_warning_sent_at].eq(nil)).
      # its been 1.week since 1st warning
      where(reminders[:has_not_verified_first_warning_sent_at].lt(threshold))
    when :third
      set.where(reminders[:has_not_verified_first_warning_sent_at].eq(nil).not).
      where(reminders[:has_not_verified_second_warning_sent_at].eq(nil).not).
      where(reminders[:has_not_verified_third_warning_sent_at].eq(nil)).
      # its been 1.week since 2nd warning
      where(reminders[:has_not_verified_second_warning_sent_at].lt(threshold))
    else
      raise "Not a valid ordinal"
    end


    # has not received either warning or disabling notification
    # where(reminders[:has_not_verified_warning_sent_at].eq(nil)).
    set = set.where(reminders[:has_not_verified_and_is_now_disabled_sent_at].eq(nil)).
      
    # company is active
    where(companies[:disabled_at].eq(nil)).

    # user is not disabled
    where(users[:status].eq(:disabled).not).
    
    # user has not verified
    where(users[:verified_at].eq(nil)).
        
    # AND haven't unsubscribed from all
    where(email_settings[:global_unsubscribe].eq(false))    
    
    return set
  end
  
  # this tells users their accounts are now disabled
  # and that they must now verify their email
  # to log back in
  def self.users_who_have_not_verified_and_need_to_be_disabled
    threshold = 1.week.ago
    
    users, reminders, companies, email_settings = User.arel_table, Reminder.arel_table, Company.arel_table, EmailSetting.arel_table
    
    set = User.includes(*INCLUDES).references(*INCLUDES).

    # has received third warning but not disabling notification
    where(reminders[:has_not_verified_third_warning_sent_at].eq(nil).not).
    where(reminders[:has_not_verified_and_is_now_disabled_sent_at].eq(nil)).
      
    # company is active
    where(companies[:disabled_at].eq(nil)).

    # user is not disabled
    where(users[:status].eq(:disabled).not).
    
    # user has not verified
    where(users[:verified_at].eq(nil)).

    # its been 24 hours since they've been warned
    where(reminders[:has_not_verified_third_warning_sent_at].lt(threshold))
    
    return set
  end
  
  def self.disable_unverified_users(users)
    users.each do |user|
            
      company = user.company

      # if this company has at least one verified user 
      if(company.users.any?{|u| u.verified_at.present?})

        Rails.logger.info " ----------------- disabling just user: #{user.id}"

      # just disable the login for this user
      # this should trigger notification
      # NOTE: I'm not sure this is necessary, and may even be problematic
      #       in the future when we implement admin of disabling users...
      #       
      user.disable!
      ReminderNotifier.delay.has_not_verified_and_is_now_disabled(user)
      Reminder.mark_sent!(user, :has_not_verified_and_is_now_disabled)
      
      # otherwise, if no one has verified
      else

        Rails.logger.info " ----------------- disabling user and company: #{user.id} - #{company.id}"

        # specifically disable this user
        user.disable!
        
        # disable whole company
        company.disable!
        
        # Notify user that their company has been disabled
        # (this really should only be sent to one user[the first] per company)
        ReminderNotifier.delay.company_disabled(user)
        Reminder.mark_sent!(user, :has_not_verified_and_is_now_disabled)
      end
    end
  end
  
  def self.companies_to_be_destroyed
    companies = Company.arel_table
    threshold = 1.week.ago
    
    set = Company.where(companies[:disabled_at].lt(threshold))
    return set
  end
  
  def self.destroy_companies(companies)
    companies.each do |c|
      begin
        Rails.logger.warn " -------------- Destroying company! #{c.id} - #{c.domain} - (#{c.users.length} users)(#{c.sent_user_recognitions_count} sent recognitions)(#{c.received_user_recognitions_count} received recognitions)"
        c.destroy
      rescue Exception => e
        Rails.logger.warn "Could not destroy company: #{c.inspect}"
        Rails.logger.warn "Exception: #{e.inspect}"
        Rails.logger.warn "#{e.backtrace}"
      end
    end
  end
  
  def self.mark_sent!(user, email)
    reminder = Reminder.find_or_initialize_by(user_id: user.id)
    reminder.mark_sent!(email)
  end

  def mark_sent!(email)
    self.send("#{email}_sent_at=", Time.now)
    self.save!    
  end
end