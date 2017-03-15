class Report::Company
  include Report::CacheManager::Company

  attr_reader :company, :from, :to, :opts

  def initialize(company, from=50.years.ago, to=Time.now, opts={})
    @company = company
    @from = from
    @to = to
    @opts = opts
  end

  def users
    company.users
  end

  def family_users
    @family_users ||= company.family_users
  end

  def interval
    opts[:interval]
  end

  def inactive?
    received_recognitions.size == 0 && sent_recognitions.size == 0
  end

  # Benchmark 5/1/2014 - metro - 27s
  def leaders
    @leaders ||= get_leaders#Rails.cache.fetch(ckm_lookup_key(:leaders)){ get_leaders }
  end

  def sent_recognitions
    @recognitions ||= company.sent_recognitions.where("recognitions.created_at >= ? AND recognitions.created_at <= ?", from, to)
  end
  
  def received_recognitions
    @received_recognitions ||= company.received_recognitions.where("recognitions.created_at >= ? AND recognitions.created_at <= ?", from, to)
  end

  def recognition_recipients
    @recognition_recipients ||= company.recognition_recipients.joins(:recognition).where("recognitions.created_at >= ? AND recognitions.created_at <= ?", from, to)
  end

  def unique_recipient_count
    recognition_recipients.uniq.pluck('recognition_recipients.user_id').size
  end

  def max_recognition_recipient_id
    RecognitionRecipient.includes(:recognition).joins(:recognition)
    .where(recipient_company_id: company.id)
    .where("recognitions.created_at >= ? AND recognitions.created_at <= ?", from, to)
    .maximum(:id)
  end

  def top_recognitions
    sent_recognitions.sort{|a,b| b.approvals_count <=> a.approvals_count}
  end

  def leaderboard_relative_to(user, attr, limit)
    set = user_leaderboard(attr).values
    i = set.index{|u| u[:id] == user.id}

    return leaderboard(set, i, limit)
  end

  def team_leaderboard(attr)
    set = company.teams.map{|t| Report::Team.new(t, from, to, opts)}
    return sort_teams_by(set, attr)
  end

  def user_leaderboard(attr)
    sort_leaders_by(attr)
  end

  def first_place_leaders(attr)
    leaders = user_leaderboard(attr)
    leaders.select{|id, leader| leader[:rank] == 1}
  end

  def first_place_teams(attr)
    teams = team_leaderboard(attr)
    teams.select{|team| team.rank == 1}
  end
    
  def top_badges(opts={})
    limit = opts[:limit] || 100000000
    set = received_recognitions.group_by(&:badge_id)
    counts = set.inject({}){|hash, (badge_id, recognitions)| hash[badge_id] = recognitions.size; hash}
    sorted_counts = counts.sort{|a,b| b[1] <=> a[1]}
    badge_counts = sorted_counts[0..limit].inject({}){ |hash, (badge_id, count)| hash[badge_id] = {badge: Badge.cached(badge_id), count: count};hash}
    return badge_counts
  end

  private

  def sort_leaders_by(attr)
    sorted_leaders = leaders.values.sort_by{|user| user[attr]}.reverse
    rank = 0
    sorted_leaders.each_with_index do |leader, index|
      leader[:behind_user] = sorted_leaders[index-1][:id] if index > 0
      leader[:in_front_of_user] = sorted_leaders[index+1][:id] if sorted_leaders.length > index + 1
      rank = (index > 0 && leader[:points] == sorted_leaders[index-1][:points]) ? rank : rank + 1
      leader[:rank] = rank
    end

    sorted_leaders.inject({}) {|hash, leader| hash[leader[:id]] = leader;hash}
  end  

  def sort_teams_by(set, attr)
    sorted_teams = set.sort_by(&attr).reverse    
    rank = 0
    sorted_teams.each_with_index do |team, index|
      rank = (index > 0 && team.send(attr) == sorted_teams[index-1].send(attr)) ? rank : rank + 1      
      team.rank = rank
    end
  end

  def leaderboard(set, index, count)
    case
    when index < (count/2) # Towards the beginnning
      leaderboard = set[0..(count-1)]

    when index > set.length-(count/2) # Towards the end
      leaderboard = set[set.length-count..set.length]  

    else # somewhere in the middle
      leaderboard = set[index-(count/2)..index+(count/2)]
    end

    return leaderboard    
  end

  def get_leaders
    # user_set = opts[:team_id].present? ? Team.find(opts[:team_id]).users : company.users
    if opts[:points_only]
      # this is fastest, as long as we only need points
      get_leaders_by_query
    else
      # for backwards compatibility
      get_leaders_by_report
    end

  end

  def get_leaders_by_query
    set = PointActivity
    .where(company_id: company.id)
    .where("point_activities.created_at >= ? AND point_activities.created_at <= ? ", from, to)
    .select("point_activities.user_id, SUM(point_activities.amount) as points")
    .group("point_activities.user_id")
    .order("points desc")


    if opts[:team_id].present?
      set = set.joins(:point_activity_teams).where(point_activity_teams: {team_id: opts[:team_id]})
    end

    if opts[:badge_id].present?
      set = set.where(badge_id: opts[:badge_id]) 
    end

    # hack for now to avoid n+1 on user query
    user_map = family_users.inject({}){|hash, user| hash[user.id] = user;hash}

    result = set.inject({}){|hash, totals| 
      user = user_map[totals.user_id]
      if user.present? # protect in case there are point activities for deleted users, shouldn't happen, but it might...
        hash[totals.user_id] = UserReportDecorator.new(user, totals)
      end
      hash
    }
    
    return result
  end

  def get_leaders_by_report
    if opts[:team_id].present?
      set = company.teams.find(opts[:team_id]).users
    else
      set = company.users
    end

    set.inject({}) do |hash, user|

      user_report = Report::User.new(user, from, to, opts)
      hash[user.id] = UserReportDecorator.new(user, user_report)
      hash
    end
  end

  class UserReportDecorator
    attr_accessor :user, :report

    def initialize(user, report)
      @user = user
      @report = report
      @attrs = {}
    end

    def [](key)
      respond_to?(key) ? send(key) : @attrs[key]
    end

    def []=(key, value)
      @attrs[key] = value
    end

    def id
      user.present? ? user.id : report.user_id
    end

    def sent_recognitions
      report.sent_recognition_count
    end

    def received_recognitions
      report.received_recognition_count
    end

    def sent_approvals
      report.sent_approval_count
    end

    def received_approvals
      report.received_approval_count
    end

    def points
      report.points
    end
  end
end