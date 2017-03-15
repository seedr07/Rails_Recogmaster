# reset badge images for company:
# prefix = "/Users/pete/work/recognize/app/assets/images/badges/200/"
# c.company_badges.each{|b| b.image = File.open(prefix+b.short_name.downcase+".png");b.save;}
#
class Badge < ActiveRecord::Base
  include Authz::PermissionsHelper

  acts_as_paranoid
  mount_uploader :image, BadgeUploader

  USER_BADGES = [:thumbs_up, :boss, :brilliant, :caring, :coffee_maker, :comedian, :cooperative, :creative, :detailed, :determined, :efficient, :friend,
    :fun, :hacker, :honorable, :innovative, :leader, :listener, :on_track, :organized, :passionate, :peace_maker,
    :popular, :powerful, :problem_solver, :provider, :punctual, :responsive, :skilled, :speaker, :speedy]

  SYSTEM_BADGES = [:on_fire, :new_user, :ambassador]
  SET = USER_BADGES+SYSTEM_BADGES
  INSTANT = [:thumbs_up]

  NOUNS = [:boss, :comedian, :friend, :hacker, :leader, :listener, :new_user, :problem_solver, :provider, :speaker]
  ADJECTIVES = SET-NOUNS

  #MAP TAGS TO BADGES
  TAG_MAP = {
    fun: [:coffee_maker, :comedian, :fun],
    encouraging: [:boss, :brilliant, :caring, :cooperative, :creative, :friend, :honorable, :thumbs_up],
    productivity: [:boss, :creative, :detailed, :determined, :efficient, :honorable]
  }

  #MAP BADGES TO TAGS
  TAG_INVERSE_MAP = TAG_MAP.inject({}){|map, tag_and_badges|
    tag = tag_and_badges[0]
    badge_array = tag_and_badges[1]
    badge_array.each{|badge| map[badge] ||= []; map[badge] << tag}
    map
  }

  # Override the default names
  # this is used by the badges factory
  # NOTE: if overriding the default name
  #       be sure to include change in a
  #       migration
  NAME_OVERRIDES = {
  }

  attr_accessor :original_id
  attr_accessible :description, :name, :short_name, :long_name, :company, :image, :image_cache, :restricted
  attr_accessible :achievement_frequency, :achievement_interval_id, :is_instant, :is_achievement, :is_nomination
  attr_accessible :disabled_at, :points
  attr_accessible :sending_frequency, :sending_interval_id, :sending_limit_scope_id

  belongs_to :company
  has_many :recognitions

  before_validation :format_names
  before_destroy :only_destroy_if_custom_badge

  validates :short_name,  presence: true
  validate :image_is_present
  # validates :name, uniqueness: {scope: [:company_id, :deleted_at]}
  validates :short_name, uniqueness: {scope: [:company_id, :deleted_at], case_sensitive: false}
  validate :can_set_as_achievement
  validate :cannot_set_instant_if_achievement
  validate :is_nomination_is_not_nil

  validates :achievement_interval_id, inclusion: {in: Interval::RESET_INTERVALS.keys}
  validates :achievement_frequency, numericality: { only_integer: true, greater_than: 0}

  scope :system_badges, -> { where(name: SYSTEM_BADGES) }
  scope :user_badges, -> { where(name: USER_BADGES).where(disabled_at: nil) }
  scope :all_user_badges, -> { where(name: USER_BADGES) }
  scope :unrestricted, -> { where(restricted: false) }
  scope :noncompany, -> { where(company_id: nil) }
  scope :achievements, -> { where(is_achievement: true) }
  scope :admin, -> { where(restricted: true) }
  scope :normal, -> { where(restricted: false, is_achievement: false) }
  scope :disabled, -> { where.not(disabled_at: nil)}
  scope :enabled, -> { where(disabled_at: nil)}
  scope :nominations, -> { where(is_nomination: true) }
  scope :recognitions, -> { where(is_nomination: false) }

  @@badges = {}
  SET.each do |b|
    self.class.send(:define_method, b) {@@badges[b] ||= where(name: b).first }
    define_method("#{b}?") { name == b }
  end

  def sending_limit_scope
    Recognition::LimitScope.find(sending_limit_scope_id || Recognition::LimitScope::SCOPE_LIMIT_BY_RECOGNITIONS)
  end

  def self.total_possible_achievement_count(user)
    count = user.company.company_badges.achievements.inject(0) do |total_count, badge|
      total_count += badge.achievement_frequency
    end
    return count
  end

  def self.add_custom!(company_id, name, image_url, opts={})
    b = Badge.new(opts)
    b.name = name.downcase.gsub(" ",'_')
    b.short_name, b.long_name = name, name
    b.company_id = company_id
    b.remote_image_url = image_url
    b.points = opts[:points] || 10
    b.save!
    return b
  end

  def points
    read_attribute(:points) || 10
  end

  def disable!
    touch(:disabled_at)
  end

  def disabled?
    disabled_at.present?
  end

  EXCLUDE_ATTRIBUTES_FROM_CLONE = ["id", "image", "created_at", "updated_at", "company_id", "deleted_at"]
  def clone_to_custom
    # raise "You may not clone a custom badge" if self.company_id.present? && !self.company.in_family?


    custom_name = self.short_name.downcase.gsub(" ",'_')
    custom_name = "#{custom_name}_#{Time.now.to_f.to_s.gsub('.', '')}"

    new_attributes = self.attributes.clone.except(*EXCLUDE_ATTRIBUTES_FROM_CLONE)
    b = Badge.new(new_attributes)
    b.name = custom_name
    b.deleted_at = self.deleted_at
    b.original_id = self.id

    # b.image = self.local_file
    # Need to account when using different storage providers(dev vs prod)
    begin
      if self.image.url.start_with?("http")
        b.remote_image_url = self.image.url
      elsif self.image.url.start_with?("/uploads")
        b.image = File.open(File.join(Rails.root, "public", self.image.url))
      elsif match = self.image.url.match(Regexp.quote("//#{Recognize::Application.config.host}"))
        path = self.image.url.gsub(match.regexp, '')
        b.image = File.open(File.join(Rails.root, "public", path))
      else
        b.image = self.local_file
      end
    rescue => e
      Rails.logger.warn "Could not add image for cloned badge(#{self.company.try(:domain)}): #{self.inspect}"
    end

    return b
  end

  def type
    if is_achievement?
      type = I18n.t('dict.achievement')
    elsif restricted?
      type = I18n.t('dict.executive')
    else
      type = I18n.t('dict.peer')
    end

    type
  end

  def custom?
    self.company_id.present?
  end

  def instant?
    is_instant?
  end

  def self.cached(id)
    Rails.cache.fetch("Badges/#{id}") do
      self.find(id)
    end
  end

  # FIXME: this should be renamed #achievement_interval
  def interval
    @interval ||= Interval.new(achievement_interval_id)
  end

  def sending_interval
    @sending_interval ||= Interval.new(sending_interval_id)
  end

  def self.update_cache!(id)
    Rails.cache.write("Badges/#{id}", self.find(id) )
  end

  def self.random_from_instant(company=nil)
    if company && company.custom_badges_enabled?
      set = company.badges.enabled
      instant_badges = set.select{|badge| badge.instant? }
      if instant_badges.present?
        instant_badges[rand(instant_badges.length)]
      else
        # try to find the thumbs up badge
        # otherwise(if its disabled), just use the first enabled badge
        set.detect{|b| b.name.to_s.match(/thumbs_up/)} || set.first

      end
    else
      Badge.send(INSTANT[rand(INSTANT.length)])
    end
  end

  def self.system_badge_ids
    @@system_badge_ids ||= Badge.system_badges.pluck(:id)
  end

  def self.top_badges(opts={})
    opts[:limit] ||= 5
    set = Recognition.where("badge_id NOT IN (?)", Badge.system_badge_ids).reorder('').group(:badge_id).order("count_badge_id desc").limit(opts[:limit]).count(:badge_id)
    set = set.inject({}){|hash, data| hash[data[0]] = {badge: Badge.cached(data[0]), count: data[1]}; hash}
    return set
  end

  def self.top_badges_for_company(company, opts={})
    # opts[:limit] ||= 5
    # set = Recognition.for_company(company).where("badge_id NOT IN (?)", Badge.system_badge_ids).reorder('').group(:badge_id).order("count_badge_id desc").limit(opts[:limit]).count(:badge_id)
    # set = set.inject({}){|hash, data| hash[data[0]] = {badge: Badge.cached(data[0]), count: data[1]}; hash}
    return self.top_badges_for_companies(company.id, opts)

  end

  def self.top_badges_for_companies(company_ids, opts={})
    opts[:limit] ||= 5

    if opts[:recognition_ids].present?
      scope = Recognition.where(id: opts[:recognition_ids])
    else
      scope = Recognition.scoped_to_companies(company_ids)
    end

    if opts[:since]
      # scope = scope.select{|r| r.created_at >= opts[:since]}
      scope = scope.where("created_at >= ?", opts[:since])
    end

    set = scope.where("badge_id NOT IN (?)", Badge.system_badge_ids).reorder('').group(:badge_id).order("count_badge_id desc").limit(opts[:limit]).count(:badge_id)
    set = set.inject({}){|hash, data| hash[data[0]] = {badge: Badge.find(data[0]), count: data[1]}; hash}
    return set

  end

  def self.add_to_system!(name)
    if SET.include?(name.to_sym)
      #TODO: check all the requirements have been met: image, style, etc...
      FactoryGirl.create("#{name}_badge")
    else
      raise "#{name} is not a valid badge name!  Please check app/models/badge.rb"
    end
  end

  def tags
    TAG_INVERSE_MAP[self.name]
  end

  def name
    (n = read_attribute(:name)) && n.to_sym
  end

  def system?
    @is_system ||= SYSTEM_BADGES.include?(self.name)
  end

  def user?
    !system?
  end

  def image_for_size(size)
    case size
    when 50
      image.small_thumb
    when 100
      image.thumb
    when 200
      image.large_thumb
    else
      image
    end
  end

  # this is really only useful when migrating core badges to the new model with company id
  # where badge images are stored in /uploads(either in public or via cdn)
  def local_path(size=200)
    "/assets/images/badges/200/#{self.name.to_s.gsub('_','-')}.png"
  end

  def local_file(size=200)
    File.open(File.join(Rails.root, "app", self.local_path))
  end

  def image_url(size=200)
    image_for_size(size).url
  end

  def permalink(size=200, protocol=Recognize::Application.config.web_protocol)
    # NOTE: action_controller.asset_host MUST be set to a fqdn, eg. http://localhost:3000/
    # url will have path to cdn image in production
    return image_url(size) #if Rails.env.production?
  end

  def in_sentence
    NOUNS.include?(self.name) ? "a #{self.short_name.downcase}" : self.short_name.downcase
  end

  def can_destroy?
    recognitions.size == 0
  end

  def points_are_redeemable?
    # FIXME: fill out with customizable database attribute or other logic
    !system?
  end

private

  def create_instance_interrogator!(m)
    method_name = m.to_s
    if match = method_name.match(/(.*)\?$/)
      if @@badges[match[1]]
        Rails.logger.debug "defining Badge.#{match[1]}.#{method_name}"

        self.class.send(:define_method,method_name) do
          self.name.to_sym == match[1].to_sym
        end

        return method(method_name)

      #@@badges should never be empty - it should be bootstrapped
      elsif @@badges.empty? and !Rails.env.production?
        #HACK!
        #for some reason we're losing the class instance variable in development mode
        #so try to recreate the accessors
        Rails.logger.warn "lost @@badges...attempting to recreate(#{method_name})"
        Badge.all.each {|b| Badge.send(b.name)}
        raise "Could not fix problem recreating accessors(#{method_name})" if @@badges.empty? and Badge.count > 0

        self.class.send(:define_method,method_name) do
          self.name.to_sym == match[1].to_sym
        end

        return method(method_name)
      end
    end
  end

  #some meta-syntactic sugar to allow lookups by badge name
  #eg Badge.new_user, Badge.powerful
  #this could also be explicitly defined by using "scope"
  #but scopes always return an array, so it wouldn't be as nice
  #as you'd have to do Badge.powerful.first
  #this also caches the lookup in a class variable hash
  @@badges = {}
  def self.create_badge_accessor!(method_name)
    Rails.logger.debug "inside create badge accessor: #{method_name}"

    #prevent infinite recursion
    unless method_name == :find_by_name

      #lookup if there is a badge with the method name
      badge_name = method_name.to_s.underscore
      badge = self.find_by_name(badge_name)

      if badge
        @@badges[badge_name] = badge
        Rails.logger.debug "defining Badge.#{badge_name}"

        (class << self; self; end).send(:define_method, badge_name) do
          @@badges[badge_name]
        end

        return method(method_name)
      end

    end
  end

  def self._reload_badges!
    @@badges = {}
    eigen = (class << Badge;self;end)
    Badge.all.each{|b|
      if eigen.method_defined?(b.name.to_sym)
        # puts "removing #{b.name}"
        eigen.send(:remove_method, b.name.to_sym)
      end
      # puts "caching: Badge.#{b.name} and Badge##{b.name}?"
      Badge.send(b.name).send("#{b.name}?")
    }
  end

  # For custom badges, user will input the short name, so we need to format
  # the name and long names
  def format_names
    self.name = self.short_name.strip.downcase.underscore.gsub(" ", '_') unless self.short_name.blank? or self.name.present?
    self.short_name = self.short_name.strip if self.short_name.present?
    self.long_name = self.short_name unless self.long_name.present?
  end

  def only_destroy_if_custom_badge
    errors.add :base, "You may not destroy a non custom badge" unless company_id.present?
    errors.blank?
  end

  def image_is_present
    errors.add(:image, "must be present") if self.image.file.blank? && !self.disabled? && !(Rails.env.test? || (Rails.env.development? && self.id.present?))
  end

  def can_set_as_achievement
    if(is_achievement? && custom? && !company.allow_achievements?)
      errors.add(:is_achievement, "is an Enterprise feature. What are you trying do here? Come on! Give us a call we\'ll make it right.")
    end
  end

  def cannot_set_instant_if_achievement
    if(is_achievement? && is_instant?)
      errors.add(:is_instant, "is not something you are going to want for achievements, for pete\'s sake.")
    end
  end

  def is_nomination_is_not_nil
    if self.is_nomination.nil?
      errors.add(:is_nomination, "may not be nil")
    end
  end
end
