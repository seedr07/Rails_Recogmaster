class Recognition < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include ActionView::Helpers::TextHelper
  include RecognitionConcern
  include TimestampConcern
  include Points::Calculator::CommonMethods
  include IntervalHelper
  include Wisper::Publisher
  include PostConcern
  
  acts_as_paranoid

  class LimitScope
    include IdNameMethods
    DATA =  [
      [ SCOPE_LIMIT_BY_RECOGNITIONS = 1, :recognition, "Recognitions"],
      [ SCOPE_LIMIT_BY_USERS = 2, :user, "Users"]
    ]
    def recognition?
      self.id == SCOPE_LIMIT_BY_RECOGNITIONS
    end

    def user?
      self.id == SCOPE_LIMIT_BY_USERS
    end
  end

  include Rails.application.routes.url_helpers
  attr_accessor :recipient_emails, :allow_guest_access, :experiment_value, :affected_participant_ids
  attr_accessor :reference_recipient # gives ability to tag a recognition with the recipient we want to focus on(eg for reporting on individuals across a set)
  attr_accessor :reference_activity # also do the same for stashing the point activity we're referencing
  attr_accessor :badge_name
  attr_accessor :has_send_limit_error

  attr_accessible :sender_id, :badge_id, :message, :sender, :recipients, :badge, :recipient_emails, :skills, :reason, :experiment_value, :post_to_yammer_wall

  # This needs to be set above recognition_recipients,
  # so that association callbacks are not executed first
  # thus destroying the association before we have a chance to stash it
  before_destroy :set_affected_participants

  belongs_to :sender, :class_name => "User", counter_cache: :sent_recognitions_count
  belongs_to :sender_company, class_name: "Company", counter_cache: :sent_recognitions_count
  belongs_to :badge
  has_many :approvals, -> {includes :giver }, class_name: "RecognitionApproval", dependent: :destroy
  has_many :comments, as: :commentable
  has_many :recognition_recipients, dependent: :destroy do
    def for_user(user)
      detect{|rr| rr.user_id == user.id}
    end
  end
  has_many :user_recipients, -> { uniq }, through: :recognition_recipients, source: :user
  has_many :point_activities

  before_validation :convert_recipient_emails_to_user
  before_validation :ensure_skipping_user_name_validation
  after_create :handle_recognitions_for_new_users
  after_create :generate_slug
  after_create :ensure_recipients_have_company_id_set

  # this used to be after_create, but had problem with sender_company counter_cache
  # not running because counter cache is run before this, and thus i'm missing sender_company_id
  # and so association is null
  before_create :ensure_company


  before_create :set_privacy
  after_create :update_user_recognitions_counter_cache
  after_create :update_company_last_recognition_created_at
  after_destroy :update_user_recognitions_counter_cache
  after_create :reset_sent_recognitions_counter_due_to_bug_in_rails
  after_destroy :update_participant_point_totals! # FIXME: this may be unnecessary as its handled by Points::ChangeObserver#destroy

  after_commit :post_message_and_activity_to_yammer!, on: :create
  after_commit on: :create do
    publish(:recognition_created, self)
  end

  validates :sender_id, :presence => true
  validates :sender_company_id, presence: true, on: :update
  validates :message, presence: true, on: :create, if: :should_require_message
  validates :badge_id, presence: {message: "must be selected"}, unless: ->{self.badge_name.present?}
  validates :slug, uniqueness: true
  validates :user_recipients, associated: true
  validate :cannot_send_to_self
  validate :only_system_users_can_send_system_badges
  validate :check_recipient_or_email
  validate :check_teams_have_users
  validate :can_send_achievement_badge
  validate :is_within_sending_limits
  validate :badge_name_is_valid

  default_scope { order "recognitions.created_at DESC, recognitions.id DESC" }

  scope :sent_by, lambda {|user| where(:sender_id => user.id)}
  scope :received_by, lambda {|user|
    includes(:recognition_recipients).joins(:recognition_recipients).
    where(recognition_recipients: {user_id: user.id})}

  # FIXME - not sure what the difference is between #user_sent and #non_system
  #         this should be consolidated - perhaps there should be a flag on badges
  #         that say "include_in_point_calculations" - and then these badges will be included
  #         in counters and point calculations - this will account for the future when we
  #         want auto sent badges to be included in point calculations and allow companies to specify
  #         certain badges from avoiding this
  scope :user_sent, lambda{ where("badge_id NOT IN (?)", Badge.system_badges.collect{|b| b.id})}
  scope :non_system, lambda{where("recognitions.sender_id <> ?", User.system_user.id)}

  def self.attributes_for_json
    @@json_attributes ||= [:id, :sender_company_id, :badge_id, :sender_id, :message, :permalink, :badge_permalink, :to_param]
  end

  INSTANT_RECOGNITION_MESSAGES=[
    "You\'re doing great work.",
    "Good job on your recent work.",
    "You deserve recognition for your work. Congrats.",
    "Thanks for doing a fantastic job.",
    "Your work is appreciated."
  ]

  def self.instant(sender, params)
    r = self.new
    r.is_instant = true
    r.sender = sender
    r.badge = Badge.random_from_instant(sender.company)
    r.message = params[:message] || INSTANT_RECOGNITION_MESSAGES[rand(INSTANT_RECOGNITION_MESSAGES.length)]

    if params[:email].present?
      user = User.where(email: params[:email]).first_or_initialize
      user.yammer_id = params[:yammer_id] if params[:yammer_id].present?
    else
      # we don't have email, because of glorious yammer's api to return inconsistent objects
      # so we have to fetch the email seperately, and then determine if they are in our system

      user = User.from_yammer(sender.yammer_client.get_user(params[:yammer_id]))
      raise ArgumentError, "Could not find user by yammer id; they may not be in your network" unless user.present?

      # check if user is already in the system
      if user = User.where(email: user.email).first_or_initialize
        # this could be dry'd up
        user.yammer_id = params[:yammer_id] if params[:yammer_id].present?

      end
    end

    user.set_status!(:invited_from_recognition) unless user.persisted? && user.active?

    r.add_recipient(user)

    return r
  end

  def self.for_company(c)
    r, rr, u, t= Recognition.arel_table, RecognitionRecipient.arel_table, User.arel_table, Team.arel_table

    scope = Recognition.joins(:recognition_recipients)
    return scope.where(r[:sender_company_id].eq(c.id).or(rr[:recipient_company_id].eq(c.id))).uniq

  end

  def self.for_companies(ids)
    # scope = Recognition.select("recognitions.*")
    Recognition.scoped_to_companies(ids).uniq
  end

  def self.scoped_to_companies(ids)
    r, rr, u, t= Recognition.arel_table, RecognitionRecipient.arel_table, User.arel_table, Team.arel_table
    scope = Recognition.joins(:recognition_recipients)
    return scope.where(r[:sender_company_id].in(ids).or(rr[:recipient_company_id].in(ids)))
  end

  def self.sent_or_received_by(user)
    return where(:id => nil).where("id IS NOT ?", nil) unless user.persisted?
    r, rr = ::Recognition.arel_table, ::RecognitionRecipient.arel_table
    includes(:recognition_recipients).references(:recognition_recipients)
    .where(r[:sender_id].eq(user.id).or(rr[:user_id].eq(user.id)))
    .where(rr[:deleted_at].eq(nil))
  end

  def badge=(new_badge)
    case new_badge
    when String
      self.badge_name = new_badge
    else
      super
    end
  end

  def participant_company_ids
    participants.collect do |p|
      if p.kind_of?(Company)
        p.id # company
      else
        p.company_id #user/team
      end
    end
  end

  def participant_ids
    participants.collect{|p| p.id}
  end

  # sender + recipients
  def participants
    (self.flattened_recipients + [self.sender]).uniq
  end

  # calling this earned_points to be over explicit so we know exactly
  # where this is being used, rather than having to search for the generic
  # word 'points' which is used all over the place
  def earned_points
    # FIXME: denormalize this and put points directly on recognition
    point_activities.first.amount if persisted? && (sender != User.system_user)
  end

  def recipients(opts={})
    set = opts[:with_deleted] ? recognition_recipients.with_deleted : recognition_recipients
    set.includes(:user)
      .joins(:user)
      .reject{|u| u.team_id.present? || u.company_id.present?}
      .map(&:user) + team_recipients + company_recipients
  end

  def user_recipients
    return super if association(:user_recipients).loaded?
    return super.with_deleted if self.deleted?

    if association(:recognition_recipients).loaded?
      self.recognition_recipients.map(&:user).uniq
    else
      super
    end
  end

  def team_recipients
    set = self.deleted? ? recognition_recipients.with_deleted : recognition_recipients
    team_ids = set.where.not(team_id: nil).pluck(:team_id)
    Team.unscoped.find(team_ids)
  end

  def company_recipients
    set = self.deleted? ? recognition_recipients.with_deleted : recognition_recipients
    company_ids = set.where.not(company_id: nil).pluck(:company_id)
    Company.find(company_ids)
  end


  def flattened_recipients
    user_recipients.reject(&:blank?)
  end

  def add_recipient(recipient)
    case recipient
    when User
      self.recognition_recipients << RecognitionRecipient.new(user: recipient)
    when Team
      @team_recipients ||= []
      @team_recipients << recipient
      users = recipient.users
      self.recognition_recipients += users.map{|user| RecognitionRecipient.new(team_id: recipient.id, user: user)}
    when Company
      @company_recipients ||= []
      @company_recipients << recipient
      users = recipient.users
      self.recognition_recipients += users.map{|user| RecognitionRecipient.new(company_id: recipient.id, user: user)}
    when String
      if recipient.match(/\@/)
        self.recipient_emails ||= []
        self.recipient_emails <<  recipient
      elsif recipient.match(/\:/)
        add_recipient(Recognition.find_recipient_from_signature(recipient))
      else
        add_recipient(User.new(email: recipient))
        # raise "Recipient type: #{recipient.class} not supported!"
      end

    else
      raise "Recipient type: #{recipient.class} not supported!"
    end
  end

  def recipients=(set)
    Array(set).each do |r|
      next unless r.present?
      add_recipient(r)
    end
    return set
  end

  def to_param
    self.slug || ""
  end

  def recognize_hashid
    self.slug # for api compatibility
  end

  def self.find(param, other=nil)
    case param
    when Integer
      super(param)
    else
      self.find_from_param(param)
    end
  end

  def self.find_from_param(param)
    where(slug: param).first
  end

  def self.find_from_param!(param)
    find_from_param(param) or raise ActiveRecord::RecordNotFound
  end

  def post_message_and_activity_to_yammer!
    if self.sender.authenticated_with_yammer?
      recognition = Recognition.find(self.id)
      if u = self.sender and u.can_post_to_yammer_wall? and self.post_to_yammer_wall?
        recognition.delay(queue: 'priority').post_to_yammer_wall!
      else
        recognition.delay(queue: 'priority').post_yammer_activity!(recognition.sender.yammer_client)
      end
    end
  end

  def post_yammer_activity!(client)
    if u = self.sender and u.authenticated_with_yammer?(client)
      # dont post public activity if restricting to group
      # TODO: its possible to make activity post "private" and only send to an explicit list
      #             of users, but that is a bit more work.
      return if u.company.post_to_yammer_group_id.present? 

      client.create_activity({activity: {
        actor: { name: u.full_name, email: u.email},
        action: "#{Recognize::Application.config.credentials["yammer"]["namespace"]}:recognize",
        object: yammer_activity_object},
        message: self.message})
    else
      Rails.logger.warn "Cannot post yammer activity - possibly because can't authenticate to yammer"
    end
  rescue Yammer::Error::BadRequest => e
    Rails.logger.error "!!! Caught Yammer::BadRequest: #{e.inspect} "
    raise e if Rails.env.production?
  rescue Exception => e
    Rails.logger.error "!!! Caught Exception: #{e.inspect} "
    raise e if Rails.env.production?
  end

  def post_to_yammer_wall!
    if u = self.sender and u.can_post_to_yammer_wall? and self.post_to_yammer_wall?
      msg = self.message + "\n" + skills_as_tags
      opts = yammer_og_object
      opts[:group_id] = self.sender.company.post_to_yammer_group_id if self.sender.company.post_to_yammer_group_id.present?
      u.yammer_client.create_message(msg, opts)
    end
  end

  def social_title
    "#{self.recipients_label} with the #{self.badge.short_name} badge"
  end

  def skills_as_tags
    if skills.present?
      self.skills.split(",").select(&:present?).map{|skill| "##{skill.strip}"}.join(", ")
    else
      ""
    end
  end

  def yammer_og_object
    {
      og_url: self.permalink,
      og_image: self.badge_permalink(200, "http:"),
      og_title: social_title,
      og_description: self.message
    }
  end

  def yammer_activity_object(opts={})
    h = {
      type: "#{Recognize::Application.config.credentials["yammer"]["namespace"]}:recognition",
      url: self.permalink(include_www: true),
      title: social_title,
      image: self.badge_permalink(200, "http:"),
      description: self.message}
    return h
  end

  def cross_company?(user)
    self.sender_company_id != user.company_id
  end

  def approvers
    approvals.collect{|a| a.giver}
  end

  def approve_by(user)
    approval = self.approvals.build(giver: user)
    approval.save
    return approval
  end

  def has_proper_recipients_for_certificate?
    self.recipients.size == 1 && self.recipients.first.kind_of?(User)
  end

  # Ok here's the deal.
  # For reporting we need to be able to send a set of recognitions that reference unique recipients
  # I accomplish this in Report::Recognition#point_activity_query
  # I do so, by dup'ing a recognition, and assigning it a reference recipient
  # Essentially, this makes the recognition class a mock or a decorator or whatever pattern floats your boat.
  # I've worked it so I won't pass the id through(which doesn't come across with a normal dupe), but
  # I will copy over the created_at value
  def dup_for_reference
    dup.tap do |r|
      r.created_at = self.created_at
      r.instance_variable_set("@association_cache", self.association_cache)
    end
  end

  # there is a quirk when you view stream page as a non admin user on recognizeapp.com domain
  # we enter this conditional and will see all the system recognitions sent by the system user
  # to have consistency, and to not freak me out in the future when i log in as another recognizeapp
  # user, have a special condition for this
  def self.streamable_recognitions(args)
    current_user = args[:user]
    network = args[:network]
    company = args[:company]

    if current_user && (current_user.admin? || network == "recognizeapp.com")
      ids = network != current_user.network ?
              Company.where(domain: network).first.recognitions.map(&:id).uniq :
              current_user.company.recognitions.where("recognitions.sender_id <> ?", User.system_user.id).map(&:id).uniq
      set = where(id: ids)
    else
      ids = company.recognitions.map(&:id)
      set = where(id: ids)
    end
    set.includes(:approvals, :badge, :sender, {:user_recipients => :avatar}).uniq
  end

  protected

  def only_system_users_can_send_system_badges
    if badge and sender and (badge.system? and !sender.system_user?) and !self.is_instant?
      errors.add(:sender_name, "Only the Recognize system may send system badges.  You're naughty.")
    end
  end

  def cannot_send_to_self
    if user_recipients.include?(sender) && recognition_recipients.detect{|rr| rr.user_id == sender.id}.team_id.blank?
      errors.add(:user_recipients, "are invalid")
      user_recipients.detect{|r| r == sender}.errors.add(:email, "may not be the same as your own email")
    end
  end

  def ensure_company
    # self.sender_company_id = self.sender.company_id
    # self.save!

    # this used to be after_create.  changing to before_create
    self.sender_company_id = self.sender.company_id if self.sender and self.sender.company_id
  end

  def convert_recipient_emails_to_user
    if self.recipient_emails.kind_of?(Enumerable)
      set = []
      self.recipient_emails.each do |e|
        if e.index("@")
          u = User.find_or_initialize_by(email: e)
          u.skip_name_validation = true
          u.set_status!(:invited_from_recognition) unless u.persisted? && u.active?
          set << u
        end
      end
      # self.user_recipients ||= []
      # self.user_recipients += set

      set.each do |user|
        self.add_recipient(user)
      end
    end
  end

  def ensure_skipping_user_name_validation
    self.user_recipients.each do |r|
      r.skip_name_validation = true
    end
  end

  def handle_recognitions_for_new_users
    if !self.sender.system_user?
      self.user_recipients.each do |r|
        if r.pending_signup_completion? or r.invited_from_recognition?
          sender.invite_from_recognition!(r, self)
        end
      end
    end
  end

  #Here are the possibilities:
  #1. The recipient input is left completely blank
  #2. A proper user is selected from the list
  #3. A user types a valid email
  #4. A user types an invalid email
  def check_recipient_or_email
    has_error = false

    unless user_recipients.present?
      if recipient_emails.present?
        recipient_emails.each do |e|
          errors.add(:user_recipients, "#{e} is not properly formatted.") unless e.match(Authlogic::Regex.email)
        end
      else
        errors.add(:sender_name, I18n.t('activerecord.errors.models.recognition.recipient_or_email'))
      end
    end

  end

  def check_teams_have_users
    team_ids = (@team_recipients || []).map(&:id)
    team_ids_without_users = team_ids - UserTeam.where(team_id: team_ids).pluck(:team_id).uniq
    if team_ids_without_users.present?
      errors.add(:recipients, I18n.t('activerecord.errors.models.recognition.check_teams_have_users'))
    end
  end

  def can_send_achievement_badge
    if badge.present? && badge.is_achievement?

      if user_recipients.length > 1 || user_recipients.any?{|r| !r.kind_of?(User)}
        errors.add(:recipients,  I18n.t('activerecord.errors.models.recognition.can_send_achievement_badge_single_user'))

      else
        start_time = badge.interval.start
        recipient = user_recipients.first
        achievement_recognitions = recipient.received_recognitions.where("created_at >= ?", start_time).where(badge_id: badge.id)
        if achievement_recognitions.size > badge.achievement_frequency
          errors.add(:recipients, I18n.t('activerecord.errors.models.recognition.can_send_achievement_badge_max_amt' ,badge: badge.short_name, interval: reset_interval_noun(badge.interval)))

        end
      end

    end
  end

  def is_within_sending_limits
    # 1. check user has not exhausted total number of recognitions(global limit)
    # 2. check if badge has explicit limit and user has not exhausted recognitions for that badge
    # 3. If no explicit badge limit, check against default limit
    if sender && sender.company.recognition_limit_frequency.present? && sender.company.recognition_limit_frequency.to_i > 0
      sender.company.recognition_limit_scope.recognition? ? 
        is_within_company_sending_limits : 
        is_within_company_sending_limits_by_user
    end

    unless self.has_send_limit_error
      if badge.present? && badge.sending_frequency.present? && badge.sending_frequency.to_i > 0
        badge.sending_limit_scope.recognition? ? 
          is_within_badge_sending_limits : 
          is_within_badge_sending_limits_by_user

      elsif sender && sender.company.default_recognition_limit_frequency.present? && sender.company.default_recognition_limit_frequency.to_i > 0
        sender.company.default_recognition_limit_scope.recognition? ? 
          is_within_default_badge_sending_limits : 
          is_within_default_badge_sending_limits_by_user
      end
    end

  end

  def is_within_badge_sending_limits
    start_time = badge.sending_interval.start
    interval_sent_recognitions_count = sender.sent_recognitions.where("created_at >= ?", start_time).where(badge_id: badge.id).size
    if interval_sent_recognitions_count >= badge.sending_frequency
      self.has_send_limit_error = true
      errors.add(:recipients, 
        I18n.t('activerecord.errors.models.recognition.is_within_badge_sending_limits', 
        frequency: I18n.t('dict.frequency.times', count: badge.sending_frequency), 
        interval: reset_interval_noun(badge.sending_interval)))
    end
  end

  def is_within_badge_sending_limits_by_user
    start_time = badge.sending_interval.start
    interval_sent_users_count = sender.sent_recognitions.where("created_at >= ?", start_time).where(badge_id: badge.id).map(&:user_recipients).flatten.size
    if (interval_sent_users_count + self.user_recipients.length) > badge.sending_frequency
      self.has_send_limit_error = true
      errors.add(:recipients, 
        I18n.t('activerecord.errors.models.recognition.is_within_badge_sending_limits_for_users', 
        added_recipients: self.user_recipients.length,
        frequency: I18n.t('dict.frequency.people', count: badge.sending_frequency), 
        interval: reset_interval_noun(badge.sending_interval)))
    end
  end

  def is_within_default_badge_sending_limits
    start_time = sender.company.default_recognition_limit_interval.start
    interval_sent_recognitions_count = sender.sent_recognitions.where("created_at >= ?", start_time).size
    if interval_sent_recognitions_count >= sender.company.default_recognition_limit_frequency
      self.has_send_limit_error = true
      errors.add(:recipients, 
        I18n.t('activerecord.errors.models.recognition.is_within_default_badge_sending_limits', 
        frequency: I18n.t('dict.frequency.badges', count: sender.company.default_recognition_limit_frequency), 
        interval: reset_interval_noun(sender.company.default_recognition_limit_interval)))
    end    
  end

  def is_within_default_badge_sending_limits_by_user
    start_time = sender.company.default_recognition_limit_interval.start
    interval_sent_users_count = sender.sent_recognitions.where("created_at >= ?", start_time).map(&:user_recipients).flatten.size
    if (interval_sent_users_count + self.user_recipients.length) > sender.company.default_recognition_limit_frequency
      self.has_send_limit_error = true
      errors.add(:recipients, 
        I18n.t('activerecord.errors.models.recognition.is_within_default_badge_sending_limits_for_users', 
        frequency: I18n.t('dict.frequency.people', count: sender.company.default_recognition_limit_frequency), 
        interval: reset_interval_noun(sender.company.default_recognition_limit_interval)))
    end   
  end

  def is_within_company_sending_limits   
    start_time = sender.company.recognition_limit_interval.start
    interval_sent_recognitions_count = sender.sent_recognitions.where("created_at >= ?", start_time).size
    if interval_sent_recognitions_count >= sender.company.recognition_limit_frequency
      self.has_send_limit_error = true
      errors.add(:recipients, 
        I18n.t('activerecord.errors.models.recognition.is_within_company_sending_limits', 
        frequency:  I18n.t('dict.frequency.badges', count: sender.company.recognition_limit_frequency), 
        interval: reset_interval_noun(sender.company.recognition_limit_interval)))
    end    
  end

  def is_within_company_sending_limits_by_user
    start_time = sender.company.recognition_limit_interval.start
    interval_sent_users_count = sender.sent_recognitions.where("created_at >= ?", start_time).map(&:user_recipients).flatten.size
    
    if (interval_sent_users_count + self.user_recipients.length) > sender.company.recognition_limit_frequency
      self.has_send_limit_error = true
      errors.add(:recipients, 
        I18n.t('activerecord.errors.models.recognition.is_within_company_sending_limits_for_users', 
        frequency: I18n.t('dict.frequency.people', count: sender.company.recognition_limit_frequency), 
        interval: reset_interval_noun(sender.company.recognition_limit_interval)))
    end  
  end

  def generate_slug
    slug = (self.id+self.created_at.to_f.to_s.gsub(".", '').to_i).to_s(32)
    self.update_attribute(:slug, slug)
  end

  # It used to work out when setting the recipient_company_id on the recognition_recipient model
  # but with commit d40c76fa85316d1cce25ecbdba4b12dca6d1effa which fixed a different issue
  # another bug was created whereby recognition_recipients where created by the recipient_company_id
  # was nil, which caused problems in some after_commit point calculations
  # This ensures that attribute is saved before the point calculation code in:
  # Recognition#update_user_recognitions_counter_cache
  def ensure_recipients_have_company_id_set
    self.recognition_recipients.each do |rr|
      rr.update_column(:recipient_company_id, rr.user.company_id) if rr.recipient_company_id.blank?
    end
  end

  def update_user_recognitions_counter_cache
    Company.unscoped do
      self.sender_company.refresh_all_counter_caches!

      set = self.recognition_recipients.with_deleted.map(&:recipient_company_id).uniq.each do |c_id|
        next unless c_id
        c = Company.find(c_id)
        c.refresh_all_counter_caches! if c_id
      end
    end
  end

  def update_company_last_recognition_created_at
    unless self.sender.system_user?
      self.sender.company.update_attribute(:last_recognition_sent_at, Time.now)
      self.user_recipients.each do |user|
        user.company.update_attribute(:last_recognition_received_at, Time.now)
      end
    end
  end

  def reset_sent_recognitions_counter_due_to_bug_in_rails
    # REMOVE ME when this bug is fixed:
    # https://github.com/rails/rails/issues/13304
    Company.reset_counters(self.sender_company_id, :sent_recognitions)
  end

  def set_affected_participants
    self.affected_participant_ids = self.participants.map(&:id)
  end

  # FIXME: not sure if this is necessary as its handled
  #        by Points::ChangeObserver#destroy
  def update_participant_point_totals!
    self.affected_participant_ids.each do |id|
      User.find(id).delay(queue: 'points').update_all_points!
    end
  end

  def should_require_message
    sender && sender.company.message_is_required? && message.blank?
  end

  def badge_name_is_valid
    if badge_name.present?
      self.badge = BadgeFinder.find(self.sender.company, self.badge_name)
      unless self.badge.kind_of?(Badge)
        badge_names = self.sender.company.company_badges.map(&:short_name).to_sentence(two_words_connector: ' or ', last_word_connector: ' or ')
        errors.add(:badge, I18n.t('activerecord.errors.models.recognition.attributes.badge_id.invalid_name', badge_names: badge_names))
      end
    end
  end
end
