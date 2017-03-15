module YammerCompany
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
  end

  def yammer_users
    return [] unless Recognize::Application.yammer_client.authenticated?
    set = Recognize::Application.yammer_client.all_users.collect do |yc|
      User.from_yammer(yc)
    end
    return set
  rescue YammerClient::Unauthorized => e
    return []
  end

  def yammer_groups
    groups = self.users.collect do |u|
      u.cached_yammer_groups
    end
    groups.flatten.uniq{|g| g.try(:id)}
  end


  def cached_yammer_groups
    Rails.cache.fetch("company-#{self.id}-yammergroups") do
      self.yammer_groups
    end
  end

  # this method presumes you've already refreshed the individual group caches on each user
  def refresh_cached_yammer_groups! 
    Rails.cache.write("company-#{self.id}-yammergroups", self.yammer_groups)
  end

  def yammer_group_cache_loaded?
    self.cached_yammer_groups.all?{|g| Rails.cache.read("company-#{self.id}-yammergroup-#{g.id}").present?}
  end

  # this is a convenience method to select a yammer client(ie token)
  # when needing to do yammer related tasks and we don't have a token handy
  # eg when working in a migration or background task
  def choose_yammer_client
    # have to be careful picking a client(ie a token) here.  Make sure its only for methods that pull data
    # that is general to the whole company, eg getting all users in a group is ok.  but calling client.current
    # would not be ok, because it is specific to a user that you may not have intended

    # so first see if the company admin has a yammer token we can use
    if self.company_admin.yammer_token.present?
      yammer_user = self.company_admin

    # otherwise, use the first user with a yammer token
    else 
      yammer_user = self.users.detect{|u| u.yammer_token}

    end

    return YammerClient.new( yammer_user.respond_to?(:yammer_token) ? yammer_user.yammer_token : nil)
  end

  # for now, this is only used on IdP to show option to sign in with Yammer
  # only check if there is at least one user signed up with yammer
  def allow_yammer_auth?
    return true
    has_at_least_one_yammer_user?
  end

  def has_at_least_one_yammer_user?
    User.where(company_id: 1).joins(:authentications).where("authentications.provider = ?", 'yammer').size > 0
  end
end  