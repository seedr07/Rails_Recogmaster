#users
# - total_points
# - sent_recognitions_count
# - received_recognitions_count

#teams
# - total_points
# - sent_recognitions_count
# - received_recognitions_count

#recognitions
# - approvals
class CompanyReporter
  @@users_table, @@recognitions_table = User.arel_table, Recognition.arel_table
  
  attr_accessor :company, :users, :teams, :recognitions
  
  class UserLite < Struct.new(:id, :email, :first_name, :last_name, :total_points, :sent_recognitions_count, :received_recognitions_count, :slug, :network)
    include HashIdConcern    
    def full_name
      return User.safe_full_name(email, first_name, last_name)
    end
  end
  
  class TeamLite < Struct.new(:id, :name, :total_points, :sent_recognitions_total, :received_recognitions_total, :network)
  end
  
  class RecognitionLite < Struct.new(:id);end

  def initialize(company, opts={})
    @company = company
    load! unless opts[:lazy_load]
  end
  
  # Here's the story with this method:
  # When we delay an email blast, it serializes 
  # the company reporter and along with it, all its instance
  # variables(company, users, teams, recognitions)
  # 1) This is heavy to serialize all these objects...(will mysql text column support it for large numbers of objects?)
  # 2) upon deserialization, the recognitions are revived from YAML into an array.  However, this array is normally a special
  # Relation array with all its special methods: where, select, order.  It appears Rails adds these methods metaprogrammatically
  # as opposed to with a module because if you look at the ancestors of both arrays, they are identical.  
  # 
  # The solution for now is a hack, and its to do a full reload of the recognitions.  This is smelly as its going to reload
  # recognitions for every user email blast when really it needs only be queryed once per company.  
  #
  # Passing this huge serialized data structure won't scale, so I thought about just passing through the only data
  # necessary which is the company id.  All the rest of the data can be regenerated, but then, I'm regenerating
  # the CompanyReporter data and queries for each user in the blast, again, no bueno.  
  #
  # Another approach would be to not generate a new background task for each user, just one per company, but this
  # has the risk of if one users email bombs out the task, it would take all the other emails with it...and potentially hold up 
  # non-related tasks
  
  # I think I should err on the side of reloading the data for each user.  It will increase size of queue, but the queue is only once a week
  # at odd hours.  This can be sharded if its a problem
  def init_with(coder)
    self.company = coder['company']
    self.users = coder['users']
    self.teams = coder['teams']
    # HACK FOR NOW: just do a full reload of recognitions
    # self.recognitions = coder['recognitions']
    self.recognitions = self.company.recognitions
    
    return self
  end
  
  def load!
    @users = load_users
    @teams = load_teams
    @recognitions = load_recognitions
  end

  def load_users
    users = nil
    time = Benchmark.realtime{
      users = @company.users.pluck(:id, :email, :first_name, :last_name, :total_points, :sent_recognitions_count, :received_recognitions_count, :slug, :network).collect{|u| UserLite.new(*u)}
    } 
    Rails.logger.debug "Reporter: load_users: #{time}"
    return users   
  end
  
  def load_teams
    team_set = {}
    final_set = []
    time = Benchmark.realtime{
    UserTeam.where(team_id: company.teams.pluck(:id)).pluck(:team_id, :user_id).each{|t| team_set[t[0]] ||= []; team_set[t[0]] << t[1]}
    team_set.each do |tid, user_id_set|
      users = User.where(id: user_id_set).pluck(:total_points, :sent_recognitions_count, :received_recognitions_count)
      total_points, sent_recognitions_total, received_recognitions_total = 0,0,0
      users.each{|u| total_points += u[0]; sent_recognitions_total += u[1]; received_recognitions_total += u[2]}
      t = Team.where(id: tid).pluck(:id, :name)[0]
      final_set << TeamLite.new(t[0], t[1], total_points, sent_recognitions_total, received_recognitions_total, company.domain)
    end
    }
    Rails.logger.debug "Reporter: load times: #{time}"
    return final_set
  end  
  
  def load_recognitions
    company.recognitions
  end
  
  def total_recognitions
    recognitions.size
  end

  def total_users
    users.length
  end  

  def total_company_points
    @total_company_points ||= users.inject(0){|sum, u| sum+u.total_points}
  end
  
  def recognitions_since(since)
    recognitions.where(@@recognitions_table[:created_at].gt(since))
  end
  
  # since_key is of :week, :month, :year
  def recognitions_received_by_user_since(user, since_key)
    @recognitions_rx_since ||= {}
    return (@recognitions_rx_since[since_key][user.id] || []) if @recognitions_rx_since.has_key?(since_key)

    Rails.logger.debug "Precaching recognitions received by company(#{company.id})"
    @recognitions_rx_since[since_key] = {}
    since = 1.send(since_key).ago

    @recognitions_rx_since[since_key] = recognitions.select{|r| r.created_at > since and r.recognition_recipients.map(&:user_id).include?(user.id)}    

    return (@recognitions_rx_since[since_key][user.id] || [])
  end

  def recognitions_sent_by_user_since(user, since_key)
    @recognitions_tx_since ||= {}
    return (@recognitions_tx_since[since_key][user.id] || []) if @recognitions_tx_since.has_key?(since_key)

    Rails.logger.debug "Precaching recognitions sent by company(#{company.id})"
    @recognitions_tx_since[since_key] = {}
    since = 1.send(since_key).ago
    
    # HACK to handle possibility that we access this after being serialized
    # and recognitions is unmarshalled but loses special array methods added in by rails
    if recognitions.respond_to?(:where)
      @recognitions_tx_since[since_key] = recognitions.where(Recognition.arel_table[:created_at].gt(since)).group_by(&:sender_id)
    else
      @recognitions_tx_since[since_key] = recognitions.select{|r| r.created_at > since}.group_by(&:sender_id)
    end

    return (@recognitions_tx_since[since_key][user.id] || [])
  end
  
  def top_employees(opts={})
    users.sort{|a,b| b.total_points <=> a.total_points}
  end
  
  def top_teams(opts={})
    set = teams.sort{|a,b| b.total_points <=> a.total_points}    

    set = set[0..opts[:limit]-1] if opts[:limit]
    return set
  end
  
  def most_sent_employees(limit=100)
    users.sort{|a,b| b.sent_recognitions_count <=> a.sent_recognitions_count}[0..limit-1]
  end
  
  def most_received_employees(limit=100)
    users.sort{|a,b| b.received_recognitions_count <=> a.received_recognitions_count}[0..limit-1]
  end
  
  def most_sent_teams
    teams.sort{ |a,b|
      b.sent_recognitions_total <=> a.sent_recognitions_total
    }    
  end
  
  def most_received_teams
    self.teams.sort{ |a,b|
      b.received_recognitions_total <=> a.received_recognitions_total
    }    
  end
  
  def most_validated_employees(limit=10)
    #TODO: OPTIMIZE!
    h = {}
    # recognitions_set = Recognition.where(id: company.recognitions.map(&:id)).includes(:user_recipients)
    recognitions_set = company.recognitions.includes(:user_recipients)
    recognitions_set.each do |r|
      r.user_recipients.each do |user|
        next unless user.company_id == self.company.id
        h[user.id] ||= OpenStruct.new(recipient: user, approval_count: 0)
        h[user.id].approval_count += r.approvals.size
      end
    end
    a = h.values.sort{|a,b| b.approval_count <=> a.approval_count}
    return a
  end

  def top_recognitions(opts={})
    limit = opts[:limit]
    
    set = recognitions
    if opts[:since]
      set = set.select{|r| r.created_at >= opts[:since]}
    end
    
    set = set.sort{|a,b| b.approvals_count <=> a.approvals_count}
    set = set[0..limit-1] if limit
    return set
  end

  def top_badges(opts={})
    # the method off of company is newer and way faster
    # so delegate to that for now
    return company.top_badges(opts)

  end
end