class Report::Team
  attr_reader :team, :from, :to, :opts, :stats
  attr_accessor :rank

  POINTS = {
      received_recognitions: 10,
      received_approvals: 5,
  }.freeze

  def initialize(team, from=50.years.ago, to=Time.now, opts={})
    @team = team
    @from = from
    @to = to
    @opts = opts
  end

  def team_points
    @team_points ||= calculate_team_points
  end

  def member_points
    @member_points ||= calculate_member_points
  end

  def total_points
    @total_points ||= team_points + member_points
  end

  def received_approval_count(set)
    @received_approval_count ||= {}
    @received_approval_count[set.hash] ||= set.map(&:approvals_count).inject(0){|sum, count| sum + count}
  end

  def team_recognitions
    team.team_recognitions
      .where("created_at >= ? AND created_at <= ?", from, to)
      .where( opts[:badge_id] ? {badge_id: opts[:badge_id]}  : true) 
  end

  def member_recognitions
    team.member_recognitions
      .where("created_at >= ? AND created_at <= ?", from, to)
      .where( opts[:badge_id] ? {badge_id: opts[:badge_id]}  : true) 
  end

  def member_recognition_recipients
    RecognitionRecipient.where(user_id: users.map(&:id))
      .joins(:recognition)
      .where("recognitions.created_at >= ? AND recognitions.created_at <= ?", from, to)
  end

  def unique_recipient_count
    member_recognition_recipients.uniq.pluck('recognition_recipients.user_id').size
  end

  def users
    team.users
  end

  private

  def calculate_team_points
   points = PointActivity
      .where(team_id: team.id)
      .where("point_activities.created_at >= ? AND point_activities.created_at <= ? ",from, to)
      .group(:activity_type, :recognition_id).to_a 
      .sum(&:amount) # for some reason doing sum in db doesn't calculate it right
    return points
  end

  def calculate_member_points
    points = PointActivity
      .where(user_id: team.users.pluck(:id))
      .where(team_id: nil)
      .where("point_activities.created_at >= ? AND point_activities.created_at <= ? ",from, to)
      .sum(:amount)
    return points
  end

  def calculate_points(set)
    points = 0
    points += received_approval_count(set) * POINTS[:received_approvals] # do this first for performance
    points += set.inject(0){|sum, r| sum+Badge.cached(r.badge_id).points}
    return points
  end
end