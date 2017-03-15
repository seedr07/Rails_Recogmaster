class Report::User
  attr_reader :user, :from, :to, :opts, :stats

  DEFAULT_POINTS = {
    sent_recognition_value: 2,
    received_approval_value: 5,
    sent_approval_value: 1
  }.freeze
    
  def initialize(user, from=50.years.ago, to=Time.now, opts={})
    @user = user
    @from = from
    @to = to
    @opts = opts
  end
  
  def points
    @points ||= calculate_points!
  end

  def redeemable_points
    @redeemable_points ||= calculate_redeemable_points!
  end
  
  def sent_recognitions
    @sent_recognitions ||= user.sent_recognitions
      .where("created_at >= ? AND created_at <= ?", from, to)
      .where( opts[:badge_id] ? {badge_id: opts[:badge_id]}  : true) 
  end
  
  def received_recognitions
    @received_recognitions ||= user.received_recognitions
      .where("created_at >= ? AND created_at <= ?", from, to)
      .where( opts[:badge_id] ? {badge_id: opts[:badge_id]}  : true) 
  end
  
  def sent_approvals
    if opts[:badge_id]
      @sent_approvals ||= user.given_recognition_approvals.
        where("recognition_approvals.created_at >= ? AND recognition_approvals.created_at <= ?", from, to)
        .joins(:recognition).where("recognitions.badge_id = ?", opts[:badge_id])
    else
      @sent_approvals ||= user.given_recognition_approvals.where("created_at >= ? AND created_at <= ?", from, to)
    end
  end
  
  def received_approval_count
    # RecognitionApproval.where(recognition_id: received_recognitions.pluck(:id)).size
    # @received_approval_count ||= received_recognitions.pluck(:approvals_count).inject(0){|sum, count| sum + count}
    @received_approval_count ||= received_recognitions.map(&:approvals_count).inject(0){|sum, count| sum + count}
  end

  def sent_recognition_count
    @sent_recognition_count ||= Recognition.where(sender_id: user.id)
      .where("recognitions.created_at >= ? AND recognitions.created_at <= ?", from, to)
      .size
  end

  def received_recognition_count
    @received_recognition_count ||= RecognitionRecipient.joins(:recognition)
      .where(recognition_recipients: {user_id: user.id})
      .where( opts[:badge_id] ? {recognitions: {badge_id: opts[:badge_id]}}  : true) 
      .where("recognitions.created_at >= ? AND recognitions.created_at <= ?", from, to)
      .size
  end

  def sent_approval_count
    @sent_approval_count ||= RecognitionApproval.where(giver_id: user.id)
      .where("recognition_approvals.created_at >= ? AND recognition_approvals.created_at <= ?", from, to)
      .size
  end

  private
    
  def calculate_points!
    # values = user.company.point_values
    # points = 0
    # points += received_approval_count * values[:received_approval_value].to_i # do this first for performance
    # points += sent_recognition_count*values[:sent_recognition_value].to_i
    # points += received_recognitions.non_system.inject(0){|sum, r| sum+Badge.cached(r.badge_id).points}
    # points += sent_approval_count*values[:sent_approval_value].to_i
    if opts[:badge_id]
      points = PointActivity
                 .where(user_id: user.id)
                 .where("point_activities.created_at >= ? AND point_activities.created_at <= ? ",from, to)
                 .everything_but_redemptions
                 .where(badge_id: opts[:badge_id])
                 .sum(:amount)
    else
      points = PointActivity
                 .everything_but_redemptions
                 .where(user_id: user.id)
                 .where("point_activities.created_at >= ? AND point_activities.created_at <= ? ",from, to)
                 .sum(:amount)
    end
    return points
  end

  # NOTE: the idea here is that redemptions will create negative point activities so doing a sum
  #       with positive and negative point activities will yield an appropriate balance.
  #       It feels a little wonky to make the negative point activities have a "redeemable" flag set to 
  #       true on that, but whatever, it kinda makes sense. 
  def calculate_redeemable_points!
    raise "Not implemented" if opts[:badge_id].present?
    points = PointActivity
               .redeemable
               .where(user_id: user.id)
               .where("point_activities.created_at >= ? AND point_activities.created_at <= ? ",from, to)
               .sum(:amount)
    return points
  end

end