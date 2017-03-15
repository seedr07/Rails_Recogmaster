class Company < ActiveRecord::Base
  include YammerCompany
  include CompanyAnalytics
  include CacheKeyManager
  include CompanyPointsConcern
  include Wisper::Publisher
  include SamlConcern

  acts_as_paranoid
  authenticates_many :user_sessions

  BETA_DOMAINS = ["wested.org", /recognizeapp[0-9]*\.com/]
  SETTINGS = [:allow_posting_to_yammer_wall,
    :allow_google_login,
    :allow_google_contact_import,
    :allow_daily_emails,
    :allow_instant_recognition,
    :allow_interval_winner_notifications,
    :allow_hall_of_fame,
    :reset_interval,
    :allow_yammer_manager_recognition_notification,
    :message_is_required,
    :recognition_limit_frequency,
    :recognition_limit_interval_id,
    :recognition_limit_scope_id,
    :default_recognition_limit_frequency,
    :default_recognition_limit_interval_id,
    :default_recognition_limit_scope_id,
    :global_privacy,
    :allow_yammer_connect,
    :allow_invite,
    :allow_teams,
    :allow_you_stats,
    :allow_top_employee_stats,
    :disable_passwords,
    :allow_rewards,
    :disable_signups,
    :allow_sms_notifications,
    :allow_nominations,
    :nomination_message_is_required
  ]

  attr_accessible :name, :website, :domain, :slug, :has_theme
  attr_accessible :requested_user_count

  belongs_to :parent_company, class_name: "Company"
  has_one :saml_configuration, dependent: :destroy
  has_one :subscription, dependent: :destroy
  has_many :child_companies, class_name: "Company", foreign_key: "parent_company_id"
  has_many :teams, dependent: :destroy
  has_many :users, -> { where "users.email <> 'app@recognizeapp.com'", includes: :avatar }, dependent: :destroy, inverse_of: :company
  has_many :sent_recognitions, class_name: "Recognition", foreign_key: "sender_company_id"
  has_many :recognition_recipients, foreign_key: "recipient_company_id", dependent: :destroy
  has_many :received_recognitions, through: :recognition_recipients, class_name: "Recognition", source: :recognition, dependent: :destroy
  has_many :badges
  has_many :line_items, inverse_of: :company, dependent: :destroy
  has_many :rewards
  has_many :redemptions, dependent: :destroy, inverse_of: :company
  has_many :company_roles
  has_many :campaigns, dependent: :destroy, inverse_of: :company

  serialize :anniversary_notifieds, Hash
  serialize :custom_labels, Hash

  before_validation :set_default_company_name

  validates :name, presence: true, on: :update, unless: Proc.new { |c| c.domain == "users" }
  validates :domain, presence: true, if: :has_parent_company?
  validates :domain, uniqueness: { scope: :deleted_at }
  validate :kiosk_mode_key_contains_proper_characters, on: :update

  before_destroy :check_subcompany_has_no_users, if: Proc.new { |c| c.parent_company_id.present? }
  after_create :create_default_teams
  after_update :run_settings_callbacks

  after_commit on: :create do
    publish(:company_created, self)
  end

  # hack to not release this feature to everyone until its tested more thoroughly
  def allow_send_limit_scope_selection?
    ["recognizeapp.com", "seegrid.com"].include?(self.domain)
  end

  def recognition_limit_scope
    Recognition::LimitScope.find(recognition_limit_scope_id || Recognition::LimitScope::SCOPE_LIMIT_BY_RECOGNITIONS)
  end

  def default_recognition_limit_scope
    Recognition::LimitScope.find(default_recognition_limit_scope_id  || Recognition::LimitScope::SCOPE_LIMIT_BY_RECOGNITIONS)
  end

  # badge that will be chosen for a recognition
  # when none is specified
  def default_badge
    self.company_badges.first
  end

  def name
    if domain == "chempoint.com"
      return "ChemPoint"
    else
      super
    end
  end

  def user_team_map
    self.users.inject({}) do |hash, user|
      team = user.teams.first
      hash[user.email] = team.name if team
      hash
    end
  end

  def add_director!(email)
    user = self.users.find_by_email(email)
    if user.director?
      raise "User is already director"
    else
      user.roles << Role.director
    end
    return user
  end

  def remove_director!(id)
    user = self.users.find(id)
    UserRole.where(user_id: user.id, role_id: Role.director.id).delete_all
    return user
  end

  def anniversary_notifieds
    an = attributes["anniversary_notifieds"]
    an.present? ? an : { role_ids: [], user_ids: [], team_ids: [] }
  end

  def nominations_enabled?(user)
    allow_nominations? && user.sendable_nomination_badges.size > 0
  end

  def company_badges
    self.custom_badges_enabled? ?
      self.badges.enabled  :
      (self.created_at < Time.parse("2014-02-23") ? Badge.all_user_badges : Badge.user_badges)
  end

  def custom_label(key, default="")
    (custom_labels && custom_labels[key]) || default
  end

  def directors
    users.is_director
  end

  def label
    "#{self.name} (#{self.domain})"
  end

  def role_is_notified_of_anniversary?(role)
    self.anniversary_notifieds[:role_ids].include?(role.id)
  end

  def team_is_notified_of_anniversary?(team)
    self.anniversary_notifieds[:team_ids].include?(team.id)
  end

  def all_teams_notified_of_anniversary?
    all_teams_notified = true
    self.teams.each do |team|
      if (!(team_is_notified_of_anniversary?(team)))
        all_teams_notified = false
      end
    end
    return all_teams_notified
  end

  # if opts[:optimize_cache_refreshing], then we can optimize
  # the busting of the cache, only bust cache on old and new companies once
  # Passing this flag makes the assumption that all users in the set are coming from the same company
  def add_users!(user_ids, opts={})
    set = User.where(id: user_ids)

    if opts[:optimize_cache_refreshing]
      old_company = set[0].company
    end

    set.each do |u|
      old_company ||= u.company
      Rails.logger.debug { "Moving user(#{u.log_label}) from (#{old_company.domain}) to (#{self.domain})" }
      u.move_company_to!(self, opts)
    end

    if opts[:optimize_cache_refreshing]
      Rails.logger.debug { "Priming COUNTER and COMPANY caches for #{old_company.domain}" }
      old_company.refresh_all_counter_caches!
      old_company.delay(queue: 'caching').prime_caches!
    end

    Rails.logger.debug { "Priming COUNTER and COMPANY caches for #{self.domain}" }
    self.refresh_all_counter_caches!
    self.delay(queue: 'caching').prime_caches!

  end

  # return all parents and sibling if any
  def family
    return [self] unless in_family?

    if child_companies.present?
      set = [self] + child_companies
    else
      set = [self.parent_company] + self.parent_company.child_companies
    end
    return set
  end

  def in_family?
    child_companies.present? or has_parent_company?
  end

  def make_child_company!(name)
    company = self.dup
    company.parent_company = self
    company.name = name
    company.domain = self.domain+"-"+name.gsub(" ", "-")
    company.slug = company.domain
    company.custom_badges_enabled_at = nil
    company.save

    if company.errors.blank?
      company.delay(queue: 'priority').enable_custom_badges! if self.custom_badges_enabled?
      company.refresh_all_counter_caches!
    end
    company
  end

  def has_parent_company?
    self.parent_company_id.present?
  end

  def child_company?
    has_parent_company?
  end

  def is_parent_company?
    Company.where(parent_company_id: self.id).exists?
  end

  def family_users(opts={})
    if opts[:includes]
      User.includes(opts[:includes]).where(company_id: self.family.map(&:id))
    else
      User.where(company_id: self.family.map(&:id))
    end
  end

  def update_badges!(badge_params)
    badges = badge_params.map do |badge_id, attrs|
      short_name, points, enabled, description = attrs["short_name"], attrs["points"], attrs["enabled"], attrs["description"]
      sending_frequency, sending_interval_id, is_nomination = attrs["sending_frequency"], attrs["sending_interval_id"], attrs["is_nomination"]
      sending_limit_scope_id = attrs["sending_limit_scope_id"]

      # nomination badges cannot be sent instantly, so override params["is_instant"]
      if is_nomination
        attrs["is_instant"] = "false"
      end

      updates = { short_name: short_name, points: points, description: description }
      updates[:disabled_at] = (enabled == "true" ? nil : Time.now)

      updates[:is_instant] = (attrs["is_instant"] == "true" ? true : false)
      updates[:is_achievement] = (attrs["is_achievement"] == "on" ? true : false)
      updates[:sending_frequency] = sending_frequency
      updates[:sending_interval_id] = sending_interval_id
      updates[:is_nomination] = attrs["is_nomination"] || false
      updates[:sending_limit_scope_id] = sending_limit_scope_id

      if updates[:is_achievement] == true && allow_achievements?
        updates[:achievement_frequency] = attrs["achievement_frequency"].to_i
        updates[:achievement_interval_id] = attrs["achievement_interval_id"].to_i
      end

      # Badge.where(id: badge_id).update_all(updates)

      badge = Badge.where(company_id: self.id, id: badge_id).first

      begin
        transaction do
          badge.update!(updates)
          new_roles = self.company_roles.where(id: attrs["roles"]).to_a
          badge.grant_permission_to_roles(:send, new_roles)
        end
      rescue => e
        # noop
      end

      Badge.update_cache!(badge_id)
      badge
    end
    # we may have changed badge point values, and thus need to update everyone's point totals
    self.delay(queue: 'points').refresh_all_user_point_totals!

    return OpenStruct.new(success: badges.all?(&:valid?), badges: badges)
  end

  def custom_badges_enabled?
    self.custom_badges_enabled_at.present?
  end

  def enable_custom_badges!
    raise "Cannot enable custom badges twice" if custom_badges_enabled?
    raise "Company must first be saved before enabling custom badges" unless self.persisted?

    set = []
    user_badges = child_company? ? self.parent_company.company_badges : Badge.all_user_badges
    user_badges = user_badges[0..3] if Rails.env.test? #Hack to speed up tests, we dont need 30 badges enabled
    user_badges.each_with_index do |b, i|
      Rails.logger.info "Cloning badge #{i}/#{user_badges.size}"
      set << b.clone_to_custom
    end
    begin
      Rails.logger.info "Assigning cloned badges"
      self.badges = set
    rescue Exception => e
      Rails.logger.warn "Caught exception enabling custom badges: #{e} - #{self.badges.inspect} - #{set.inspect}"
      set.each { |b| Rails.logger.warn "Errors(#{b.name}): #{b.errors.full_messages.to_sentence}" }
      raise e
    end
    touch(:custom_badges_enabled_at)

    # update all recognitions that were sent from this company to have proper badge id
    self.badges.each do |b|
      Recognition.where(sender_company_id: self.id, badge_id: b.original_id).update_all(badge_id: b.id)
      # Recognition.update_all(["badge_id = ?", b.id], ["sender_company_id = ? AND badge_id = ?", self.id, b.original_id])
    end
  end

  def enable_admin_dashboard!
    update_attribute(:allow_admin_dashboard, true)
  end

  def enable_theme!
    update_attribute(:has_theme, true)
  end

  def enable_achievements!
    update_attribute(:allow_achievements, true)
  end

  def show_achievements?
    allow_achievements? && has_achievement_badges?
  end

  def has_achievement_badges?
    self.company_badges.achievements.size > 0
  end

  def has_sent_or_received_recognitions?

    # first condition checks a recognition was sent via the web platform
    result = self.recognitions.joins(:sender)
      .non_system
      .where(from_inbound_email_id: nil)
      .where("recognitions.created_at >= users.verified_at")
      .count


    result > 0

    # second condition checks against edge case where maybe there were multiple
    # recognitions sent via email, in most cases once recognitions start being sent
    # we'll never reach the 2nd condition, so only 1 query will be executed
    # self.recognitions.non_system.where.not(from_inbound_email_id: nil).count > 1

  end

  def email
    company_admin.email
  end

  def company_admins
    @company_admins ||= self.users.select { |u| u.company_admin? }
  end

  def company_admin
    @company_admin ||= self.users.detect { |u| u.company_admin? }
  end

  def recognitions(reload=false)
    # sniff, sniff...this code smells...
    if reload
      @recognitions = Recognition.for_company(self)
    else
      @recognitions ||= Recognition.for_company(self)
    end
  end

  def recognitions_for_badge(badge_id)
    recognitions.where(badge_id: badge_id)
  end

  def to_param
    self.domain
  end

  def refresh_cached_users!
    self.reload
    Rails.cache.write("company-#{self.id}-all_users", self.all_users)
  end

  def cached_users(opts={})
    begin
      if opts[:skip_cache]
        set = all_users(as_map)
      else
        set = Rails.cache.fetch("company-#{self.id}-all_users", opts[:cache]) do
          self.all_users
        end
      end
      return set
    rescue TypeError => e
      au = self.all_users
      Rails.logger.warn "CACHE ERROR: #{e}"
      Rails.logger.warn "#{au.inspect}"
      return au
    end
  end

  def all_users
    set = self.users.inject({}) { |h, rc| h[rc.email] = rc; h }
    self.yammer_users.each { |yc| set[yc.email] ||= yc }
    return set
  end

  def self.beta_domain?(domain)
    return false if domain.blank?
    BETA_DOMAINS.any? { |d| domain.match(d) }
  end

  def beta_domain?
    Company.beta_domain?(self.domain)
  end

  def has_one_verified_user?
    self.users.any? { |u| u.verified? }
  end

  def self.from_email(email)
    return nil unless email.index("@")
    domain = email.split("@").last
    c = Company.find_or_initialize_by(domain: domain).tap { |c| c.slug = domain }
    c.name = domain.split(".")[0..domain.count('.')-1].map { |w| w.capitalize }.join(' ') unless c.persisted? #default name is the domain split out sans the tld
    return c
  end

  def self.attributes_for_json
    @@json_attributes ||= [:id, :name, :slug, :domain]
  end

  def self.has_other_users_in_domain?(user)
    user_domain = User.blacklisted_email?(user.email) ?
        "users" :
        user.email.split("@")[1]

    company = where(domain: user_domain).first
    company and company.users.where("users.id <> #{user.id}").present?
  end

  def has_team?(name)
    self.teams.any? { |t| t.name == name }
  end

  def disabled?
    disabled_at.present?
  end

  def disable!
    self.update_attribute(:disabled_at, Time.now)
  end

  def active?
    !disabled? and deleted? and has_one_verified_user?
  end

  def has_one_active_user?
    self.users.any { |u| u.active? }
  end

  def self.prime_caches!
    Company.scoped.each do |c|
      c.prime_caches!
    end
  end

  def prime_caches!
    Rails.logger.debug "#{Time.now.to_formatted_s(:db)} - Refreshing cached users for(#{self.domain})"
    self.refresh_cached_users!
    self.users.each do |u|
      u.delay(queue: 'caching').prime_caches!
    end
    self.refresh_cached_yammer_groups!
  end

  def calculate_received_recognitions_count
    Recognition.joins(:recognition_recipients).
        where(recognition_recipients: { recipient_company_id: self.id }).count(:id)
  end

  def calculate_received_user_recognitions_count
    Recognition.joins(:recognition_recipients).
      where(recognition_recipients: { recipient_company_id: self.id }).
      where("recognitions.badge_id NOT IN (?)", Badge.system_badges.pluck(:id)).count
  end

  def calculate_sent_user_recognitions_count
    Recognition.where(["sender_company_id = ? AND badge_id NOT IN (?)", self.id, Badge.system_badges.pluck(:id)]).size
  end

  def update_received_recognitions_counter_cache!
    self.update_attribute(:received_recognitions_count, self.calculate_received_recognitions_count)
  end

  def update_received_user_recognitions_counter_cache!
    self.update_attribute(:received_user_recognitions_count, self.calculate_received_user_recognitions_count)
  end

  def update_sent_recognitions_counter_cache!
    Company.where(id: self.id).update_all(sent_recognitions_count: self.sent_recognitions.count)
  end

  def update_sent_user_recognitions_counter_cache!
    self.update_attribute(:sent_user_recognitions_count, self.calculate_sent_user_recognitions_count)
  end

  def update_recognition_limits(params)
    self.default_recognition_limit_interval_id = params[:default_recognition_limit_interval_id]
    self.default_recognition_limit_frequency = params[:default_recognition_limit_frequency]
    self.default_recognition_limit_scope_id = params[:default_recognition_limit_scope_id]
    self.recognition_limit_interval_id = params[:recognition_limit_interval_id]
    self.recognition_limit_frequency = params[:recognition_limit_frequency]
    self.recognition_limit_scope_id = params[:recognition_limit_scope_id]
    self.save
  end

  def update_kiosk_mode_key(key)
    self.kiosk_mode_key = key
    self.save
  end

  def kiosk_mode_key_contains_proper_characters
    if kiosk_mode_key.present? && (!kiosk_mode_key.match(/^[a-zA-z0-9]+$/))
      errors.add(:kiosk_mode_key, I18n.t("activerecord.errors.models.company.kiosk_key_format"))
    end
  end

  COUNTER_CACHES = {
    :update_received_recognitions_counter_cache! => :received_recognitions_count,
    :update_received_user_recognitions_counter_cache! => :received_user_recognitions_count,
    :update_sent_user_recognitions_counter_cache! => :sent_user_recognitions_count
    # :update_sent_recognitions_counter_cache!, :update_users_counter_cache!
  }

  def refresh_all_counter_caches!
    COUNTER_CACHES.keys.each do |m|
      self.send(m)
    end
    self.attributes.keys.each do |attr|
      next unless attr.match(/_count$/)
      next if COUNTER_CACHES.value?(attr.to_sym)
      # explicitly skip disabled counter caches
      # FIXME - remove these attributes
      # Ugh, this is terrible...2016/01/30
      next if [:sent_recognitions_count, :requested_user_count].include?(attr.to_sym)
      Company.reset_counters(self.id, attr.gsub(/_count$/, ''))
    end
  end

  def refresh_all_user_point_totals!
    self.users.each do |u|
      u.delay(queue: 'points').update_all_points!
    end
    Report::CacheManager::Company.delay(queue: 'priority_caching').bust_and_reprime_report_caches!(self.id)
  end

  def update_global_privacy(privacy)
    flag = (privacy.downcase == "on" ? true : false)
    self.update_attribute(:global_privacy, flag)
  end

  def allows_public_recognitions?
    !self.global_privacy?
  end

  def top_badges(opts={})
    Badge.top_badges_for_company(self, opts)
  end

  def update_settings!(settings)
    if (settings.has_key?("global_privacy"))
      privacy_on_off = (settings["global_privacy"] == "true" ? "on" : "off");
      update_global_privacy(privacy_on_off)
    else
      settings.each do |name, value|
        self.send("#{name}=", value)
      end
    end
    save!
  end

  def get_user_ids_by_role_id(role_id)
    user_ids = []
    self.users.each do |user|
      if (user.roles.map(&:id).include?(role_id))
        user_ids.push(user.id)
      end
    end
    return user_ids
  end

  def self.reset_intervals
    Interval::RESET_INTERVALS
  end

  def default_recognition_limit_interval
    @default_recognition_limit_interval ||= Interval.new(default_recognition_limit_interval_id)
  end

  def recognition_limit_interval
    @recognition_limit_interval ||= Interval.new(recognition_limit_interval_id)
  end

  def add_external_user!(inviter, attributes)
    user = self.users.build(attributes)
    user.skip_same_domain_check = true

    inviter.invite_user!(user)
  end

  def resend_invitations!(sender, status=:pending_invite)
    set = self.users.where(status: status)
    set.each do |user|
      sender.resend_invite!(user)
    end
  end

  protected

  def create_default_teams
    set = []
    Team.default_set.each do |t|
      set << Team.new(name: t).tap { |t| t.company = self }
    end
    transaction do
      set.map { |team| team.save! }
    end
  end

  def run_settings_callbacks
    SETTINGS.each do |setting|
      if send("#{setting}_changed?") && respond_to?("#{setting}_has_changed!", true)
        send("#{setting}_has_changed!")
      end
    end
  end

  def allow_daily_emails_has_changed!
    if self.allow_daily_emails?
      user_ids = self.users.pluck(:id)
      EmailSetting.where(user_id: user_ids).update_all(daily_updates: true)
    end
  end

  def reset_interval_has_changed!
    Points::Resetter.new(self).reset!
  end

  def set_default_company_name
    self.name = self.domain if self.name.blank?
  end

  def check_subcompany_has_no_users
    if parent_company_id.present? && self.users.present?
      errors.add(:base, "Cannot delete department while there are users. Please reassign users to a different department.")
      return false
    end
  end
end
