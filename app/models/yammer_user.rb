module YammerUser

  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def by_yammer_id(yammer_id, client)
      yammer_user = User.where("yammer_id IS NOT NULL").where(yammer_id: yammer_id).first
      yammer_user ||= User.from_yammer(client.get_user(yammer_id))
      yammer_user        
    end
    
    def yammer_image_from_template(template, opts={})
      if opts[:height] and opts[:width]
        template.gsub('{width}x{height}', "#{opts[:width]}x#{opts[:height]}")
      else
        template.gsub('{width}x{height}', '200x200')
      end
    end
  
    def from_yammer(data)
      return nil if data.blank?
      
      email = data.email.present? ? data.email : User.yammer_primary_email(data)
      
      unless u = User.where(email: email).first
        u = User.new(email: email)
      end
      
      if data.first_name
        u.first_name = data.first_name
        u.last_name = data.last_name
      else
        u.first_name, u.last_name = data.full_name.split(" ", 2)
      end
      u.mugshot_url = data.mugshot_url
      u.mugshot_url_template = data.mugshot_url_template
      u.external_source = "yammer"
      u.yammer_id = data.id
      return u
    end
    
    def yammer_primary_email(yammer_user)
      yammer_user.contact.email_addresses.first{|e| e.type == "primary"}.address rescue nil
    end
  end

  ##############################
  #
  # Instance Methods
  #
  ##############################
  def can_post_to_yammer_wall?
    auth_with_yammer? && company.allow_posting_to_yammer_wall? && company.allow_yammer_connect?
  end

  def invite_from_yammer!(users, yammer_client = self.yammer_client)
    results = {}
    return results if users.blank?
    
    #we want to stash multiple attributes of the yammer user in the invite(email, first name, last_name)
    #instead of passing a single parameter(say email address), and then doing an individual request per
    #invite, we send through all the attributes in the http request, and due to the nature of http inputs
    #we need to filter out only ones that have the invite key(which means it was checked)
    users = users.select{|id, params| params.has_key?("invite")}
    users.each do |y_id, yammer_user|
      if yammer_user[:email].blank?        
        yu = yammer_client.get_user(y_id)
        yammer_user[:email] = User.yammer_primary_email(yu)
      end

      invited_user = add_user!(yammer_user[:email]) do |user|
        user.first_name = yammer_user[:first_name]
        user.last_name = yammer_user[:last_name]
        
        #massage yammer avatar url
        if au = yammer_user[:avatar_url]
          au += ".jpg" unless File.extname(au).present?
          user.avatar.remote_file_url = au
        end
        user.yammer_id = y_id
      end
      results[yammer_user[:email]] = invited_user
      sleep 1
    end
    
    return results
  end
  
  def coworkers_on_yammer(randomize=false, limit=200, exclude_in_system=true)
    yc = Recognize::Application.yammer_client
    current_yammer_user = yc.current

    set = []
    set += self.company.yammer_users

    # find yammer users in recognize, so that we can reject them
    # existant_set = self.company.users.where(email: set.collect{|u| u.email}).pluck(:email)
    existant_set = self.company.users.where("yammer_id IS NOT NULL").pluck(:yammer_id)    

    # reject yammer users that are already in the system
    new_yammer_users = set.reject{|u| existant_set.include?(u.yammer_id)}.uniq{|r| r.yammer_id}

    # take 200 random users
    # new_yammer_users = new_yammer_users.shuffle if randomize
    # new_yammer_users = new_yammer_users[0..limit] if limit
      
    return new_yammer_users
    # return set  
  rescue YammerClient::Unauthorized => e
    return []
  end

  def cached_relevant_coworkers
    Rails.logger.debug {"#{Time.now.to_formatted_s(:db)} --- Cached relevant coworkers --- user-#{self.log_label}-relevant_users"}
    set = Rails.cache.fetch(ckm_cache_key(:relevant_coworkers)) do
      self.relevant_coworkers
    end
    set.uniq{|u| u.email || u.object_id}.uniq{|u| u.yammer_id || u.object_id}
  end
  
  def refresh_cached_relevant_coworkers!(client = self.yammer_client)
    Rails.logger.debug {"#{Time.now.to_formatted_s(:db)} --- Refresh Cached relevant coworkers --- user-#{self.log_label}-relevant_users"}
    # Rails.cache.write(relevant_coworkers_cache_key, self.relevant_coworkers(client))
    # Yammer's suggested users api call was taking way too long(10sec/req)
    # so we're going to defer the reloading of the cache.  all we need to do is update the cache key
    ckm_touch(:relevant_coworkers)
  end

  def relevant_coworkers(client = self.yammer_client)
    return [] unless client.authenticated?

    Rails.logger.debug {"#{Time.now.to_formatted_s(:db)} - Fetching relevant coworkers for user(#{self.log_label})"}
    current_yammer_user = client.current
    set = []
    
    set1 = self.yammer_followers(current_yammer_user)
    set2 = self.users_following_on_yammer(current_yammer_user)
    # set3 = self.suggested_yammer_users

    Rails.logger.debug {"#{Time.now.to_formatted_s(:db)} - completed fetching relevant user algorithm"}
    
    set = set1 + set2# + set3

    Rails.logger.debug {"#{Time.now.to_formatted_s(:db)} - calling uniq!"}
    set.uniq!

    Rails.logger.debug {"#{Time.now.to_formatted_s(:db)} - returning set"}
    return set 
  end

  # get users on yammer that are following this user
  def yammer_followers(yammer_user, client = self.yammer_client, fetch_email = true)
    return [] unless client.authenticated?
    Rails.logger.debug {"#{Time.now.to_formatted_s(:db)} - Fetching yammer followers for user(#{self.log_label})"}

    set = client.users_following(yammer_user.id).users.try(:collect) do |u|
      User.from_yammer(u)
    end

    return set || []
  rescue YammerClient::Unauthorized => e
    return []    
  end

  # NOT SURE IF THIS IS WORKING PROPERLY
  # users that this user is following
  def users_following_on_yammer(yammer_user, client = self.yammer_client)
    return [] unless client.authenticated?
    Rails.logger.debug {"#{Time.now.to_formatted_s(:db)} - Fetching users that this user follows: (#{self.log_label})"}

    set = client.users_followed_by(yammer_user.id).users.try(:collect) do |yc|
      User.from_yammer(yc)
    end
    return set || []
  rescue YammerClient::Unauthorized => e
    return []    
  end

  def suggested_yammer_users(client = self.yammer_client)
    return [] unless client.authenticated?
    Rails.logger.debug {"#{Time.now.to_formatted_s(:db)} - Fetching suggested yammer users: (#{self.log_label})"}

    suggestions = nil
    Rails.logger.debug(" -- BENCHMARK: Fetching suggested users for(#{self.log_label}): "+Benchmark.realtime {
      suggestions = client.get("/api/v1/suggestions")
    }.to_s)

    Rails.logger.debug {"#{Time.now.to_formatted_s(:db)} - Fetched suggestions for(#{self.log_label}), now loading set into User objects"}

    set = suggestions.collect do |yc|
      User.from_yammer(yc.suggested)
    end
    Rails.logger.debug {"#{Time.now.to_formatted_s(:db)} - completed loading suggestions for(#{self.log_label} into User objects"}

    return set
  rescue YammerClient::Unauthorized => e
    return []    
  end

  def cached_yammer_groups
    Rails.cache.fetch("user-#{self.id}-yammergroups") do
      self.yammer_groups
    end
  end

  def refresh_cached_yammer_groups!(client = self.yammer_client)

    Rails.logger.debug "#{Time.now.to_formatted_s(:db)} - Refreshing yammer group cache on user(#{self.log_label})"

    # refreshing the group cache for this user
    Rails.cache.write("user-#{self.id}-yammergroups", self.yammer_groups(client))

  end

  def yammer_groups(client = self.yammer_client)
    return [] unless self.yammer_id.present? and client.authenticated?
    client.all_groups
  rescue YammerClient::Unauthorized => e
    client.handle_unauthorized(e, self)
  end

  # This is the main api method used by RecognitionsController
  # to get coworkers to recommend in instantRecognition feature
  def yammer_group_coworkers
    set = []
    self.cached_yammer_groups.each do |group|
      set += self.company.cached_yammer_group_contacts(group.id)
    end
    return set
  end

  def sync_yammer_avatar!
    return unless self.yammer_id.present?

    y = self.authentications.yammer
    return unless y.present?
    yammer_token = y.credentials.token

    if yammer_token
      client = YammerClient.new(yammer_token)
      user = client.get_user(self.yammer_id)
      image_url_template = user.mugshot_url_template
      self.assign_yammer_avatar(image_url_template)
      self.avatar.save!
    end
  rescue YammerClient::Unauthorized => e
    Recognize::Application.yammer_client.handle_unauthorized(e, self)
  end

  def assign_yammer_avatar(yammer_mugshot_url)
    return unless yammer_mugshot_url.present?
    return if yammer_mugshot_url.match(/no_photo/)

    image_url = User.yammer_image_from_template(yammer_mugshot_url)
    # image_url += ".jpg" # MAJOR HACKAGE: yammer mugshot urls come through without file extension :(
    begin
      self.avatar.remote_file_url = image_url    
    rescue NoMethodError => e
      Rails.logger.warn("------")
      Rails.logger.warn("yammer mugshot url: #{yammer_mugshot_url}")
      Rails.logger.warn(e.backtrace)
      Rails.logger.warn("------")
      raise e
    end
  end

  def get_yammer_token
    authentications.yammer ? authentications.yammer.credentials.token : nil
  end

  def yammer_token
    @yammer_token ||= get_yammer_token
  end
  
  # is this user object from yammer's source
  def from_yammer?
    self.external_source == "yammer"
  end
  
  def authenticated_with_yammer?(yammer_client=self.yammer_client)
    # self.authentications.select{|a| a.provider == "yammer"}.present? and yammer_client.authenticated?
    auth_with_yammer?
  end

  # quick and dirty check if the user has a yammer token
  # use User#authenticated_with_yammer?(yammer_client) for a more thorough check
  def auth_with_yammer?
    yammer_token.present?
  end

  def allow_yammer_auth?
    !self.authenticated_with_yammer? && !self.personal_account? && self.company.allow_yammer_connect?
  end
  
  def yammer_client
    Rails.cache.fetch(yammer_client_cache_key) do
      load_yammer_client
    end
  rescue ArgumentError => e
    Rails.cache.write(yammer_client_cache_key, load_yammer_client)
    retry
  end

  # NOTE - in real life, shouldn't really need this
  # because if token changes, the key will change and
  # will auto refresh
  def refresh_yammer_client!
    @yammer_token = get_yammer_token #refresh the cache
    Rails.cache.write(yammer_client_cache_key, load_yammer_client)
    yammer_client
  end

  def yammer_client_cache_key
    if Rails.configuration.local_config.has_key?('prevent_yammer_requests')    
      "yammer-client-#{self.id}-#{self.yammer_token}-mock-#{Time.now}"
    else
      "yammer-client-#{self.id}-#{self.yammer_token}"
    end
  end

  def yammer_client_cached?
    Rails.cache.read(yammer_client_cache_key) || false
  end

  def load_yammer_client
    yc = YammerClient.new(self.yammer_token, self)
    yc.current if self.yammer_token.present?
    yc
  rescue YammerClient::Unauthorized => e
    yc.handle_unauthorized(e, self)
    return yc
  end
end