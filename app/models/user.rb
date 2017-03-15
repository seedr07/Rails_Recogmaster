######################################################################################################################
#
# Possible states of a user: 
# 
# active: 
#    a user is all signed up and fully able to use all features their role has access to
# 
#  invited: 
#    an email has been sent to this users email address and no further action has yet been taken by the invitee
# 
#  invited_from_recognition:
#    you can recognize people by their email address.  This poses a chicken/egg argument about whether to create
#    the recognition first or user first.  Can't create the recognition first, but creating the user first without
#    knowing if the recognition succeeds is a bit of a problem.  Also, we want to have a special invite/recognition
#    email and not send the default invite and recongition emails.
#
#  pending email verification: 
#    a user has completed signup of there own volition and they have not yet verified their email address.  
#    Only applies to users that have signed up after the first user.  
# 
#  pending invite:
#    we can add users and not immediately send an invitation email. 
#    once we send the invitation email, they will be moved to "invited" status.
#
#  NOTE: when a user verifies their email from "pending email verification", "invited", or "invited from recognition"
#            the user will go to "pending_signup_completion", as a temporary state until they set their password
#            once they put in their password, they become "active"
# 
#  pending signup completion: 
#    a user has initiated signup and is the first user for their company but has not yet completed signup. 
#    They are considered to have completed signup once they have saved a password.      
#
#  disabled
#    a user has been disabled because they have not verified their email
#
#  UPDATE: 11/29/2013
#    - a first user who signs up for a company through signup form will have state as 'pending_signup_completion' but will
#      move to 'active' once they set a password
#    - the second user for a company who signs up through signup form will have state 'pending_email_verification'
#
######################################################################################################################
class User < ActiveRecord::Base

  include Role::UserMethods
  include YammerUser
  include CacheKeyManager
  include UserAnalytics
  include Points::Calculator
  include UnsubscribeConcern

  class Lite < Struct.new(:id, :email, :network, :label, :avatar_thumb_url)
    include HashIdConcern
    def self.model_name
      User.model_name
    end

    def first_name
    end

    def last_name
    end
  end
  acts_as_paranoid  

  extend EmailBlacklist
  
  STATES = [:pending_signup_completion, :pending_email_verification, :invited, :invited_from_recognition, :pending_invite, :queued, :active, :disabled]
  
  attr_accessor :original_password, :force_password_validation, :invitations, :skip_original_password_check
  attr_accessor :external_source, :mugshot_url, :mugshot_url_template
  attr_accessor :created_by, :acting_as_superuser, :skip_name_validation, :skip_same_domain_check
  attr_accessor :new_record_temporary_id
  attr_accessor :bypass_disable_signups
  attr_accessor :has_changes_to_send_to_close

  attr_accessible :email, :password, :original_password, :first_name, :last_name, :teams, :company, :avatar, :company_attributes, :job_title
  attr_accessible :email_setting_attributes, :created_by, :slug, :yammer_id
  attr_accessible :start_date, :company_id, :network, :locale, :from_inbound_email_id
  attr_accessible :phone
 
  serialize :has_read_features

  has_many :user_company_roles
  has_many :company_roles, through: :user_company_roles do
    def add(role)
      self.push(role) unless self.exists?(role)
    end

    def remove(role)
      self.delete(role) if self.exists?(role)
    end
  end
  has_many :company_role_permissions, through: :company_roles
  has_many :proxy_permissions, through: :company_role_permissions, source: "permission"
  has_many :user_permissions
  has_many :direct_permissions, through: :user_permissions, source: "permission"


  belongs_to :company, counter_cache: :users_count, inverse_of: :users
  has_many :user_teams, dependent: :destroy
  has_many :teams, :through => :user_teams
  has_many :authentications, inverse_of: :user, dependent: :destroy do
    def find(id_or_provider)
      if id_or_provider.to_i > 0
        where(id: id_or_provider)
      else
        where(provider: id_or_provider)
      end
    end
    def yammer
      select{|a| a.provider == "yammer"}.last
    end

    def google
      select{|a| a.provider == "google_oauth2"}.last
    end

    def office365
      select{|a| a.provider == "office365"}.last
    end

  end
  
  has_many :user_roles, before_add: :ensure_directors_are_company_admins
  has_many :roles, through: :user_roles

  has_many :received_recognitions, through: :recognition_recipients, source: :recognition, dependent: :destroy
  has_many :recognition_recipients, dependent: :destroy
  has_many :sent_nomination_votes, :class_name => "NominationVote", :foreign_key => "sender_id", dependent: :destroy
  has_many :received_nominations, class_name: "Nomination", as: :recipient, dependent: :destroy
  has_many :sent_recognitions, :class_name => "Recognition", :foreign_key => "sender_id", dependent: :destroy
  has_many :received_badges, :through => :received_recognitions, :source => :badge
  has_many :sent_badges, :through => :sent_recognitions, :source => :badge
  has_many :invited_users, :class_name => "User", :foreign_key => "invited_by_id"
  has_many :given_recognition_approvals, class_name: "RecognitionApproval", foreign_key: "giver_id", dependent: :destroy
  has_many :comments, foreign_key: "commenter_id"
  has_many :oauth_access_tokens, foreign_key: "resource_owner_id", class_name: "Doorkeeper::AccessToken"

  has_many :team_managers, foreign_key: "manager_id", dependent: :destroy

  has_one :avatar, as: :owner, class_name: "AvatarAttachment", autosave: true
  has_one :email_setting, dependent: :destroy, inverse_of: :user, autosave: true, validate: true
  has_one :reminder, dependent: :destroy
  has_one :contact_list, inverse_of: :user
  belongs_to :invited_by, class_name: "User", foreign_key: "invited_by_id", counter_cache: :invited_users_count
  has_one :subscription
  has_many :point_activities, dependent: :destroy
  has_many :redemptions, dependent: :destroy, inverse_of: :user
  has_many :device_tokens
  
  acts_as_authentic do |c|
    c.disable_perishable_token_maintenance = true
    c.merge_validates_format_of_email_field_options({ :scope => :deleted_at, :allow_blank => true})
    c.merge_validates_length_of_password_field_options({ if: :should_validate_password?, on: :update})
    c.merge_validates_length_of_password_field_options({:minimum => 6})
    c.merge_validates_uniqueness_of_email_field_options(scope: [:deleted_at,:network], message: :email_uniqueness)
    c.require_password_confirmation = false
    c.maintain_sessions = false
  end 
    
  validates :email, :status, :slug, presence: true
  validates :first_name, :last_name, presence: true, if: :should_validate_name?
  validates :company, presence: true, if: Proc.new{|u| u.errors[:email].blank?}
  validates :network, presence: true, if: lambda{|u| u.company.present?}
  validates :status, inclusion: { in: STATES }
  validates :slug, uniqueness: {scope: [:network, :deleted_at, :status], message: Proc.new{|a,b|  "'#{b[:value]}' has been taken"}}
  # validates :phone, format: {with: /\+1[02-9][\d]{9}/}, if: ->{ phone.present? }

  validate :email_is_within_domain
  validate :slug_contains_proper_characters, on: :update
  validate :changing_password_must_include_original_password
  validate :has_no_password
  validate :network_in_company_family, unless: Proc.new{|u| u.personal_account? }
  validate :company_does_not_have_signups_restricted, on: :create

  before_validation :trim_email
  before_validation :set_account_type, on: :create
  before_validation :ensure_company
  before_validation :ensure_network
  before_validation :ensure_state
  before_validation :ensure_slug, on: :create
  before_validation :format_phone
  
  before_create :build_email_settings
  after_create :add_default_user_role
  after_create :update_company_last_created_at
  after_create :handle_new_or_existing_domain_users
  after_create :bust_company_stats_cache
  after_update :handle_change_of_company

  ATTRIBUTES_TO_SEND_TO_CLOSE = ["phone", "job_title", "first_name", "last_name", "email"]
  after_create { self.has_changes_to_send_to_close = true }
  after_update { 
    self.has_changes_to_send_to_close = true if (ATTRIBUTES_TO_SEND_TO_CLOSE & self.changes.keys).present?
  }

  after_commit do
    Rails.logger.info "User#after_commit - about to upsert"
    Recognize::Application.closeio.delay(queue: 'sales').upsert_contact(self.id) if has_changes_to_send_to_close && consider_as_contact?
  end

  after_commit on: :create do
    EmailTemplateReply.delay(queue: 'sales', run_at: 5.minutes.from_now).send_sales_reply(self.id) if consider_as_contact? && !company.allow_admin_dashboard? && authentications.yammer.blank?
  end

  accepts_nested_attributes_for :company, :email_setting
  
  scope :queued, -> { where(status: "queued") }
  scope :not_disabled, -> { where("status <> 'disabled'") }
  scope :is_director, -> {joins(:user_roles).where(user_roles: {role_id: Role.director.id})}
  scope :pending_invite, -> { where(status: :pending_invite) }

  # default_scope { joins(:user_roles).uniq }

  def grant(permission)
    direct_permissions << permission
  end

  def revoke(permission)
    direct_permissions.delete(permission)
  end

  def permissions
    (proxy_permissions + direct_permissions).uniq
  end

  def consider_as_contact?
    first_user_ids = self.company.users.where("status not like '%invite%'").order("created_at asc").limit(3).pluck(:id)
    first_user_ids.include?(self.id)
  end

  def invited_by
    User.unscoped { super } #allows association to be deleted
  end

  def subscribed_account?
    # self.subscription.purchased? or self.company.subscription.purchased? rescue false
    self.company.allow_admin_dashboard? or self.company.subscription.try(:purchased?)
  end

  def find_or_build_subscription(plan, coupon, opts={})
    opts.merge!({email: self.email})
    subscription = self.subscription || self.build_subscription.tap{|s| s.company_id = self.company_id}
    subscription.assign_attributes(opts)
    subscription.plan = plan
    return subscription
  end

  #might be time to put create_subscription! out to pasture
  def create_subscription!(plan, coupon, params)
    subscription = find_or_build_subscription(plan, coupon, params)
    subscription.save_with_payment!
    return subscription
  end

  def prime_caches!
    Rails.logger.debug {"#{Time.now.to_formatted_s(:db)} - Priming caches for user(#{self.log_label})"}
    if self.auth_with_yammer?
      self.refresh_yammer_client!
      self.refresh_cached_user_graph!
      self.delay(queue: 'caching').refresh_cached_yammer_groups!
      self.refresh_cached_relevant_coworkers!
    end

    Rails.logger.debug {"#{Time.now.to_formatted_s(:db)} - Refreshing cached contacts"}
    self.refresh_cached_contacts! # this doesn't hit yammer and so we don't need to sleep
    self.update_all_points!
  rescue YammerClient::Unauthorized => e
    Recognize::Application.yammer_client.handle_unauthorized(e, self)
  end

  # users who do not have global unsubscribe checked
  def self.marketable_users
    set = self.joins(:email_setting).includes(:email_setting, :company => :subscription)
      .where(email_settings: {global_unsubscribe: false})
      .where(status: "active")
    set.reject{|u| u.company.subscription.try(:purchased?) || u.company.subscription.cancelled?  }
  end

  def self.marketable_yammer_users
    marketable_users.where.not(yammer_id: nil)
  end

  def self.find_or_create_by_oauth(oauth)
    #user = User.find_or_create_by(email: oauth.email, created_by: :oauth)
    user = User.where(email: oauth.email).first_or_initialize(created_by: :oauth)
    user.apply_oauth(oauth)
    return user
  end

  def years_of_service
    return DateTime.now.year - self.start_date.year
  end
  
  def apply_oauth(oauth)   
    auth = authentications.build(:provider => oauth.provider, :uid => oauth.uid, :credentials => oauth.credentials)    
    info = oauth.oauth.extra.raw_info

    self.email = oauth.email
    self.first_name = oauth.first_name
    self.last_name = oauth.last_name

    if oauth.yammer? and self.avatar.default? and !oauth.default_image?
      image_url_template = oauth.data.mugshot_url_template
      self.assign_yammer_avatar(image_url_template)
      self.job_title = oauth.data.try(:job_title)
      
    elsif oauth.google?
      begin
        self.avatar.remote_file_url = oauth.image
      rescue NoMethodError => e
        Rails.logger.warn("------")
        Rails.logger.warn("oauth image: #{oauth.image.inspect}")
        Rails.logger.warn(e.backtrace)
        Rails.logger.warn("------")
        raise e
      end      
    end
  end
  
  def sync_google_contacts
    # for new users who are oauth'ing, we not have linked them to their company yet
    # so do a manual company look up 
    if company.allow_google_contact_import? && self.authentications.google.present?
      token = self.authentications.google.credentials.token
      self.contact_list ||= ContactList.new
      self.contact_list.update_attributes!(user: self, contacts: GoogleClient.new(token).get_contacts_emails)
    end
  end

  def show_google_login?
    !self.authenticated_with_google? && self.company.allow_google_login? && !self.authenticated_with_yammer?
  end

  def can_view_hall_of_fame?
    company.allow_hall_of_fame? || HallOfFame.whitelist.include?(self.email)
  end

  def can_view_rewards?
    company.allow_rewards?
  end

  def authenticated_with_google?
    self.authentications.select{|a| a.provider == "google_oauth2"}.present?
  end
    
  def formatted_email
    # hack because with amazon SES requires senders to be verified
    "#{self.full_name} <donotreply@recognizeapp.com>"
  end

  def accepts_email?(setting=nil)
    return true if self.email_setting.blank?
    accepts = !self.email_setting.global_unsubscribe 
    #setting can be nil so we can allow checking for global unsubscribe
    accepts &&= self.email_setting.send(setting) if self.email_setting.respond_to?(setting)
    return accepts
  end
  
  def first_user_for_company?
    if u = self.company.users.order("users.created_at asc, users.id asc").first
      u.id == self.id
    else 
      false
    end
  end
  
  def has_read_feature?(feature)
    (has_read_features ||  {})[feature].present?
  end
  
  def has_read_feature!(feature)
    features = has_read_features || {}
    features[feature] = true
    update_attribute(:has_read_features, features)
  end
  
  def self.signup!(user_params)
    user = User.new(user_params)
    user.skip_name_validation = true
    user.save # this is weird that its not bang.
    
    return user
  end
  
  def update_profile(user_params)
    avatar_file = user_params.delete(:avatar)
    company_id = user_params.delete(:company_id)

    success = true

    success &&= update_attributes(user_params)
    
    if success and avatar_file
      success &&= update_avatar(avatar_file)
    end
    
    if success and company_id && company_id.to_i != self.company_id.to_i
      success &&= assign_company(company_id)
    end

    return success
  end

  def assign_company(id)
    company = Company.find(id)
    return false unless company

    company.add_users!(self.id)
    return true #this smells
  end
  
  def update_avatar(file)
    avatar_attachment = AvatarAttachment.new(file: file)
    return update_attribute(:avatar, avatar_attachment)
  rescue NoMethodError => e
    Rails.logger.warn("------")
    Rails.logger.warn(e.backtrace)
    Rails.logger.warn("------")
    FileUtils.cp(file.tempfile, (Rails.root+"log/"+file.original_filename).to_s)
    raise e
  rescue ActiveRecord::RecordNotSaved => e
    if avatar_attachment.errors
      self.errors.add(:base, avatar_attachment.errors.full_messages.to_sentence)
    else
      self.errors.add(:base, "There was an error uploading.  Please try a different file.")
    end
    return false
  end
  
  def recognize!(recipients, badge, message, opts={})
    recipients = [recipients] unless recipients.kind_of?(Enumerable)
    badge = badge || self.company.default_badge
    
    recognition = self.sent_recognitions.new(
      recipients: recipients, 
      badge: badge, 
      message: message)

    recognition.post_to_yammer_wall = opts[:post_to_yammer_wall]
    recognition.from_inbound_email_id = opts[:from_inbound_email_id]

    recognition.save!
    recognition
  end
  
  def invite!(emails, recognition=nil, opts={})
    emails = [emails] unless emails.kind_of?(Array)
    new_users = []
    emails.each do |e|
      next if e.blank?
      e = e.index("@") ? e : "#{e}@#{self.company.domain}"
      opts[:bypass_disable_signups] = true
      new_users << add_user!(e, recognition, opts)
    end
    return new_users
  end

  def invite_from_recognition!(user, recognition, opts={})
    add_user!(user, recognition, opts)
  end

  def invite_user!(user)
    add_user!(user)
  end

  def resend_invite!(user)
    user.update_column(:invited_by_id, self.id)
    user.reset_perishable_token!
    user.set_status!(:invited)    
    UserNotifier.delay(queue: 'priority').invitation_email(user)    
  end

  def add_user_without_invite!(user, opts={})
    add_user!(user, nil, {skip_invitation: true}.merge(opts))
  end

  # we don't want to use the deleted_at scope
  # company should always return for a user
  def company
    Company.unscoped { super }
  end

  def badge_counts
    badge_counts_id_array = self.received_recognitions.group(:badge_id).count(:badge_id)
    badge_counts_array = badge_counts_id_array.map{|id, count| [Badge.cached(id), count]}
    badge_counts_map = Hash[badge_counts_array]
    return badge_counts_map
  end
    
  def avatar_thumb_url
    avatar.thumb.url
  end

  def avatar_small_thumb_url
    if mugshot_url_template.present?
      User.yammer_image_from_template(mugshot_url_template, {width: 100, height: 100})
    else
       avatar.small_thumb.url
    end
  end
  
  def label
    self.full_name
  end
  
  def type
    "User"
  end

  def log_label
    "#{self.id} - #{self.email}"
  end

  def as_json(options={})
    options[:only] ||= [:id, :first_name, :last_name, :email]
    options[:methods] ||= [:avatar_thumb_url, :label, :network_label, :type]

    super(options)
  end

  # useful for hiding "users" network
  def network_label
    network == "users" ? "" : network
  end


  protected

  #this method allows manipulation of the user object just
  #after its creation, useful in the case of wanting to 
  #set first and last name from Yammer
  # ALSO: this method used to be called #send_invitation!
  #       but that was too specific and invitations aren't even
  #       handled here, they're handled by UserObserver and
  #       switch on the user's status
  def add_user!(user_or_email, recognition=nil, opts={}, &block)
    
    #allow stubs or full emails, but force company domain
    # email = email_stub.split("@")[0]+"@"+self.company.domain 
    # return User.new() if User.exists?(email: email)
    u = user_or_email.kind_of?(User) ? user_or_email : User.new(email: user_or_email)#self.company.users.build(email: user_or_email)

    yield u if block_given?
    
    st = recognition.present? ? 
      :invited_from_recognition : 
      (opts[:skip_invitation] ? :pending_invite : :invited)

    u.company = opts[:company] if opts[:company].kind_of?(Company)
    u.skip_same_domain_check = true if opts[:skip_same_domain_check]
    u.bypass_disable_signups = opts[:bypass_disable_signups]
    u.set_status!(st)
    u.invited_at = Time.now
    u.invited_by = self
    u.skip_name_validation = true unless user_or_email.kind_of?(User)
    # recognition.present? ? u.save : u.save!#(validate: false)
    u.invited_from_recognition? ? u.save! : u.save
    return u
  end

  public 
  def email_to_slug
    email_slug = email.split("@")[0].gsub('.','-').gsub(/[+']/, '-')
    email_slug += "1" if User.where(network: self.network, slug: email_slug).exists?
    self.string_contains_letter?(email_slug) ? email_slug : "user-#{email_slug}"
  end
  
  # users who you are connected to via recognitions(sent or received)
  def recognition_graph
    set = {}
    connection_set = []

    # get all the connections ids(sender and recipients of recognitions)
    connection_set = self.recognitions.non_system.collect{|r| 
      [r.sender_id, r.recognition_recipients.map{|rr| rr.user_id}]
    }.flatten.uniq
    connections = User.where(id: connection_set).where("users.id <> #{self.id}")
    set = connections.inject({}){|h, c| h[c.email] = c;h }
    return set
  end

  # users in the company and users connected via recognitions
  def user_graph
    set = self.personal_account? ? {} : self.company.cached_users
    set.merge! self.recognition_graph        
    return set
  end

  def cached_user_graph
    Rails.cache.fetch("user-#{self.id}-graph") do
      self.user_graph
    end
  end

  def refresh_cached_user_graph!
    Rails.logger.debug "#{Time.now.to_formatted_s(:db)} - Refreshing cached user graph for user(#{self.log_label})"
    Rails.cache.write("user-#{self.id}-graph", self.user_graph)
  rescue TypeError => e
    ug = self.user_graph
    Rails.logger.warn "CACHE ERROR(user.rb#refresh_cached_user_graph): #{e}"
    Rails.logger.warn "#{ug.inspect}"
    return ug
  end

  def coworkers(term=nil, opts={})
    default_avatar_url = AvatarAttachmentUploader.new.default_url
    limit = (opts[:limit] || 100000000000).to_i
    matching_set = {}
    
    terms = nil

    set = self.cached_user_graph || []
    set.delete(self.email) unless opts[:include_self]

    # Algorithm
    # CachedGraph is reduced to matching set
    # If matching set is less than limit
    #   - back fill with cached contacts(google contacts)
    # Else matching set is greater than or equal to limit
    #   - assign CachedGraph(bigger than matching set) to matching set
    #   - seems to backfill with cached contacts up to limit ? (but this may never hit??)
    if term
      Profiler.step("search graph") {      
      terms = term.split(/[\+\s]/).collect{|t| Regexp.quote(t)}
      set.each do |email, user|
        Profiler.step("search user: #{user.email}") {
        if user.matches_terms?(terms)
          matching_set[email] ||= user
        end
        }
        break if matching_set.length >= limit
      end
      }

      # add in personal contacts
      if matching_set.length < limit
        Profiler.step("search contacts") {
        self.cached_contacts.each do |email,name| 
          prefix,domain = email.split("@")
          next if domain.blank?
          domain.gsub!(/(.*)\.[^.]*$/, '\1') #chop out tld
          result = true
          Profiler.step("search contact: #{email}(#{matching_set.length})") {
          terms.each do |t|
            result &&= (prefix =~ /#{t}/i or 
              (domain =~ /#{t}/i) or 
              (name.present? and name =~ /#{t}/i))
          end
          }
          if result
            Profiler.step("add contact: #{email}") {
            label = name || email.split("@")[0]
            matching_set[email] ||= User::Lite.new(nil, email, self.network, label, default_avatar_url)
            }
          end
          break if matching_set.length >= limit
        end
        }
      end
    else
      # the first matching set(from cached user graph)
      # may  be smaller than limit
      matching_set = set
      if matching_set.length < limit
        self.cached_contacts[0..(limit-(matching_set.length-1))].each do |email, name|
          matching_set[email] ||= User::Lite.new(nil, email, self.network, label, default_avatar_url)
        end
      end
    end

    #HACK to make sure this user didn't end up in the set
    # set.delete(self.email)
    return matching_set.values
  end
  
  def matches_terms?(terms)
    prefix, domain= email.split("@")
    return false unless prefix.present? and domain.present?

    domain.gsub!(/(.*)\.[^.]*$/, '\1') #chop out tld
    result = true

    terms.each do |t|
      result &&= 
        (self.first_name.to_s =~ /#{t}/i or
        self.last_name.to_s =~ /#{t}/i or
        prefix =~ /#{t}/i or
        domain =~ /#{t}/i)
    end
    return result
  end

  def cached_contacts
    set = Rails.cache.fetch("user-#{id}-contacts") do 
      if self.contact_list.present?
        self.contact_list.try(:contacts)
      else
        []
      end
    end
  end

  def refresh_cached_contacts!
    Rails.cache.write("user-#{id}-contacts", self.contact_list.present? ? self.contact_list.try(:contacts) : [])
  end

  def self.attributes_for_json
    @@json_attributes ||= [:id, :email]
  end
  
  def self.system_user
    @@system_user ||= User.find_by_email("app@recognizeapp.com")
  end

  def sendable_badges
    # reject badges that have an explicit role, leaving ones that are non-restricted, basically
    # FIXME: this should be wrapped better by the library
    unrestricted_badges = self.company.company_badges.reject{|b| b.roles_with_permission(:send).present? }
    whitelisted_badges_by_role = Authz::Manager.new(self).find(:send, Badge)
    set = unrestricted_badges + whitelisted_badges_by_role
    set.reject(&:disabled?)
  end

  def sendable_nomination_badges
    sendable_badges.select(&:is_nomination?)
  end

  def sendable_recognition_badges
    sendable_badges.reject(&:is_nomination?)
  end

  def create_team!(team_params)
    team = self.company.teams.build(team_params)
    team.users << self
    team.creator = self
    team.team_managers.build(manager: self)
    team.save!
    team
  end

  def add_team!(team_id)
    success = true

    if(self.teams.map(&:id).include?(team_id.to_i))
      return success
    end

    team = self.company.teams.find(team_id)
 
    self.teams << team
    success = (self.errors.count == 0)
    team.delay(queue: 'points').update_all_points! if success

    return success
  end

  def remove_team!(team_id)
    success = true
   
    unless(self.teams.map(&:id).include?(team_id.to_i))
      return success
    end

    team = self.company.teams.find(team_id)
    self.teams.delete(team)
    success = self.errors.count == 0

    team.delay(queue: 'points').update_all_points! if success
    return success
  end
    
  def verified?
    self.verified_at.present? or self.authentications.present?
  end
  
  def verify!(opts={})
    self.update_column(:verified_at, Time.now)
  
    #its possible that I could verify after I've completed signup(in the case of the first user)
    #so only update the status accordingly
    self.set_status!(:pending_signup_completion) unless self.active?
  
    return self
  end
  
  #use this method when a user has authenticated but you aren't sure
  #where in the flow they should be.  It lets them login and sets the 
  #appropriate state so they are sent to the correct point in the signup flow
  def verify_and_activate!
    self.verify! unless self.verified?
    
    # hack to make sure people who come in via yammer get their verified_at column
    # set properly
    self.update_column(:verified_at, Time.now) if self.verified_at.blank?

    #this used to be in signups controller and password resets controller
    #but moving to here, because we use this method in more spots
    #and i made management of perishable token manual(instead of authlogic handling it)
    #so be safe and reset it whenever we verify
    self.reset_perishable_token!
  
    #activate if all the info is good
    self.set_status!(:active) if self.ok_to_login?
  end
  
  def set_status!(new_status)
    if persisted?
      self.update_column(:status, new_status)
    else
      self.status = new_status
    end
  end  
  
  def friendly_status
    # TODO: abstract out the status to show a better status label
    #       for each internal status
    self.status.to_s.humanize
  end
  
  def avatar_with_default
    avatar_without_default or self.build_avatar
  end
  alias_method_chain :avatar, :default unless instance_methods(false).include?(:avatar_without_default)
  
  def deliver_password_reset_instructions!  
    self.reset_perishable_token!  
    UserNotifier.password_reset_instructions(self).deliver
  end  
  
  def self.safe_full_name(email, first_name, last_name)
    if first_name.present?
      "#{first_name} #{last_name}"
    else
      email.split("@")[0].titleize.gsub('.', ' ') if email.present?
    end
  end
  
  def full_name
    return User.safe_full_name(self.email, self.first_name, self.last_name)
  end

  def recognitions
    Recognition.sent_or_received_by(self)
  end
  
  def role_symbols
    roles.map do |role|
      role.name
    end
  end  
  
  def ok_to_login?
    persisted? and company.name.present? and verified? and (crypted_password.present? or authentications.present?)
  end
  
  def is_on_team?(team_name)
    self.teams.any?{|t| t.name == team_name}
  end
  
  def disable!(opts={})
    self.set_status!(:disabled)
  end
  
  def top_recognitions
    self.recognitions.sort{|a,b| b.approvals_count <=> a.approvals_count}
  end
  
  def recognitions_sent_since(since)
    self.sent_recognitions.where(Recognition.arel_table[:created_at].gt(since))
  end
  
  def recognitions_received_since(since)
    self.received_recognitions.where(Recognition.arel_table[:created_at].gt(since))
  end
  
  def personal_account?
    self.network == "users"
  end

  def company_name
    @company_name ||= self.company.name
  end

  #some meta-syntactic sugar to allow lookups by role name
  #eg User.first.admin?
  #this also caches the lookup in a class variable hash
  def method_missing(method_name, *args, &block)
    #creator method will return nil if we can't create the method
    proc = create_role_interrogator!(method_name)
    return proc.call if proc.respond_to?(:call) 

    proc = create_state_interrogator!(method_name)
    return proc.call if proc.respond_to?(:call) 

    super
  end

  def move_company_to!(new_company, opts={})
    old_company = self.company

    self.update_columns(company_id: new_company.id, network: new_company.domain)

    # need to disconnect user from old companies teams
    UserTeam.where(user_id: self.id).delete_all

    # also clean up team manager associations
    TeamManager.where(manager_id: self.id).delete_all

    # DONT MOVE RECOGNITIONS
    # Recognitions should stay where they are earned b/c you can't move badges
    # As such, users keep their recognitions across companies in their profiles
    # as well as keeping their points. However, aggregate calculations on team and company
    # should not include disconnected recognitions

    # # clean up received recognitions that were part of team
    # RecognitionRecipient.where(recipient_id: self.id, team_id: old_company.teams.map(&:id)).delete_all

    # # clean up point activities that were part of team
    # PointActivity.where(user_id: self.id, team_id: old_company.teams.map(&:id)).delete_all

    # # update sent recognitions
    # Recognition.where(sender_id: self.id).update_all(sender_company_id: new_company.id)

    # # update received recognitions
    # RecognitionRecipient.where(recipient_id: self.id, team_id: nil).update_all(recipient_company_id: new_company.id, recipient_network: new_company.domain)

    # # update point activities
    # PointActivity.where(user_id: self.id, team_id: nil).update_all(company_id: new_company.id, network: new_company.domain)

    # # update users points
    # self.update_all_points!

    #update old company team points
    old_company.teams.map(&:update_all_points!)

    unless opts[:optimize_cache_refreshing]
      old_company.refresh_all_counter_caches!
      old_company.delay(queue: 'caching').prime_caches!
    end
  end


  def can_send_achievements?
    company_admin? || team_managers.present?
  end


  def allow_invite?
    self.company.allow_invite? || company_admin?
  end

  def allow_teams?
    self.company.allow_teams?
  end

  def allow_stats?
    self.company.allow_you_stats? || self.company.allow_top_employee_stats?
  end

  def allow_you_stats?
    self.company.allow_you_stats?
  end

  def allow_top_employee_stats?
    self.company.allow_top_employee_stats?
  end

protected
  def trim_email
    self.email = email.strip if self.email.present?
  end

  def set_account_type
    if User.blacklisted_email?(self.email) && !self.skip_same_domain_check
      self.network = "users"
    end
  end
  #we validate the password when there is a company name AND the company name hasn't changed
  #which is the case right after we assign company name during signup 
  #but also validate whenever changing the password
  #or when we're updating the password
  def should_validate_password?
    if self.crypted_password_changed?
      return true
    elsif self.force_password_validation
      return true
    else
      return false
    end
  end

  def should_validate_name?
    self.skip_name_validation.blank?
  end

  def ensure_slug
    if self.personal_account?
      self.slug = Thread.current.object_id.to_s(32)+Time.now.to_f.to_s.gsub('.','').to_i.to_s(32)
    else
      self.slug = self.email_to_slug if self.email.present?
    end
  end

  def format_phone
    if self.phone.present?
      # Twilio::PhoneNumber#format will return nil if number is invalid. 
      formatted_number = Twilio::PhoneNumber.format(self.phone)
      if formatted_number
        self.phone =  formatted_number
      else
        self.errors.add(:phone, "is invalid")
      end
    end
  end
  
  def ensure_state
    if self.status.blank?
      self.status = :pending_signup_completion
    elsif !status.kind_of?(Symbol)
      self.status = status.to_sym
    end
  end
  
  def ensure_company
    if self.company.blank? and self.email.present?
      if self.personal_account?
        company = Company.find_by_domain("users")
      else
        company = Company.from_email(self.email) if self.email.match(Authlogic::Regex.email)
      end
      self.company = company
    end
  end
  
  def ensure_network
    if self.company.present? and self.network.blank? and !self.personal_account?
      self.network = self.company.domain
    end
  end

  def ensure_directors_are_company_admins(user_role)
    if user_role.role == Role.director && !self.roles.include?(Role.company_admin)
      self.roles << Role.company_admin
    end
  end
  
  def add_default_user_role
    self.roles << Role.employee
  end
  
  def create_role_interrogator!(m)
    method_name = m.to_s
    if match = method_name.match(/(.*)\?$/) 
      role = Role.send(match[1]) rescue nil
      if role
        Rails.logger.debug "defining User.instance.#{method_name}" 
      
        self.class.send(:define_method,method_name) do
          # self.roles.include?(Role.send(match[1]))
          self.user_roles.any?{|r| r.role_id == Role.send(match[1]).id}
        end

        return method(method_name)
      end
    end    
  
  end

  def create_state_interrogator!(m)
    method_name = m.to_s
    if match = method_name.match(/(.*)\?$/) and STATES.include?(match[1].to_sym)
      Rails.logger.debug "defining User.instance.#{method_name}" 
      
      self.class.send(:define_method,method_name) do
        self.status.to_s == match[1]
      end
      return method(method_name)
    end    
    
  end

  def email_contains_a_letter
    prefix = (self.email and self.email.split("@")[0])
    if prefix and !self.string_contains_letter?(prefix)
      errors.add(:email, I18n.t('activerecord.errors.models.user.prefix'))
    end
  end

  def slug_contains_proper_characters
    if slug.present? and !self.string_contains_letter?(slug)
      errors.add(:slug, I18n.t("activerecord.errors.models.user.one_letter"))
    elsif slug.present? and !slug.match(/^[a-zA-z0-9\-_\+]+$/)
      errors.add(:slug, I18n.t("activerecord.errors.models.user.slug_format"))
    end
  end

  def string_contains_letter?(str)
    str.match(/[a-zA-Z]+/)
  end

  def email_is_within_domain
    if self.company && self.email_changed? && !self.personal_account? && !skip_same_domain_check
      new_domain = self.email.split("@")[1]
      if new_domain && (new_domain.downcase != self.company.domain.downcase)
        errors.add(:email, I18n.t("activerecord.errors.models.user.email_domain"))
      end
    end
  end
    
  def handle_new_or_existing_domain_users
    if skip_same_domain_check || Company.has_other_users_in_domain?(self)
      self.set_status!(:pending_email_verification) unless self.pending_invite? || self.invited? || self.invited_from_recognition?
    else
      self.roles << Role.company_admin
      self.company.teams.each{|t| t.creator = self; t.save! }

      unless (self.invited? and self.invited_by.company_id == self.company_id)  or self.invited_from_recognition?
        #this will get fired when we're creating the system user, so prevent it from sending itself this recognition
        #which if happens will cause an error in creating the system user and fugh everything else up
        # NOTE: the check must as specified as opposed to self.system_user?, I'm not sure why...
        recognition = User.system_user.recognize!(self, Badge.ambassador, "For showing leadership in starting recognition.")  unless User.system_user == self          
      end
    end
  end

  def bust_company_stats_cache
    Report::CacheManager::Company.delay(queue: 'priority_caching').bust_and_reprime_report_caches!(self.company_id)
  end

  def handle_change_of_company
    if company_id_changed? and company_id_change[0].present?
      self.sent_recognitions.update_all("sender_company_id = #{company_id_change[1]}")
    end
  end

  def changing_password_must_include_original_password
    if password_changed? and crypted_password_was.present? and !skip_original_password_check
      errors.add(:original_password, "must be included to change your password") if original_password.blank?
      errors.add(:original_password, "does not match your original password") if  original_password.present? and !valid_password?(original_password)
    end
  end

  def has_no_password
    if self.company && self.company.disable_passwords? && (self.password.present? || self.original_password.present?)
      errors.add(:base, "Password can not be set due to company policy.")
    end
  end

  # check if the assigned network matches the domains
  # of the company's family(as specified via company id)
  def network_in_company_family
    if self.company && !self.company.family.map(&:domain).include?(self.network)
      #FIXME: UPDATE TRANSLATION
      errors.add(:network, I18n.t('activerecord.models.user.errors.all_users_are_valid', default: 'is not a valid department.'))
    end
  end

  def company_does_not_have_signups_restricted
    if self.company && self.company.disable_signups? && !self.bypass_disable_signups
      errors.add(:base, "At the moment, only certain people are able to use Recognize in your company. Talk to your HR representative to find out more.")
    end
  end
  
  def build_email_settings
    self.build_email_setting
  end

  def should_validate_user_attrs
    # we check the "skip_original_password_check" here which is to 
    # skip validations except password when we're resetting the password
    self.active? and !self.skip_original_password_check
  end
  
  def update_company_last_created_at
    self.company.update_attribute(:last_user_created_at, Time.now) unless self.company.users_count < 1
  end

  private
  #very private method, only meant to be used in seeds and tests
  #but i'm putting here so its all in one place
  def self._create_system_user!
    unless User.exists?(User.system_user)
      system_user = User.new(first_name: "Recognize", last_name: "Team", email: "app@recognizeapp.com")
      #hack to fix tests
      #for some reason, there is weird excon error...
      unless Rails.env.test?
        f = File.open(Rails.root.join("app/assets/images/chrome/logo_180x180.png"))
        system_user.avatar.file = f
      end
      system_user.send(:ensure_company)
      system_user.send(:ensure_network)
      system_user.send(:ensure_slug)
      system_user.save(validate: false)
      system_user.company.send(:initialize_point_values)
      system_user.company.save
      system_user.roles = [Role.system_user]
      system_user.company.update_attribute(:name, "Recognize App")
    end
  end
  
  # this is used only for debugging
  def sessions
    @@session_set ||= ActiveRecord::SessionStore::Session.all.select{|s| s.data.has_key?("user_credentials_id")}
    @@session_set.select{|s| s.data["user_credentials_id"] == self.id}
  end
end
