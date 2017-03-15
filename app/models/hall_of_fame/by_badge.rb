class HallOfFame::ByBadge
  attr_accessor :company, :user, :badge, :interval, :opts

  def self.winners(company, user, badge, interval_code, opts={})
    new(company, user, badge, interval_code, opts).winners
  end

  def initialize(company, user, badge, interval_code, opts)
    @company = company
    @user = user
    @badge = badge
    @interval = Interval.new(interval_code)
    @opts = opts
  end

  def winners
    date = Time.now
    end_date = company.created_at
    groups = []
    while(date > end_date)
      Rails.logger.debug "[HALLOFFAME] ByBadge#winners - #{date}"
      date = interval.shift(time: date, shift: -1)
      winning_group = grouper.winners(company, user, date, badge_id: badge.id, team_id: opts[:team_id])
      groups << winning_group if winning_group.has_winners?
    end
    return groups
  end

  def grouper
    case 
    when interval.weekly?
      HallOfFame::ByWeek
    when interval.monthly?
      HallOfFame::ByMonth
    when interval.quarterly?
      HallOfFame::ByQuarter
    when interval.yearly?
      HallOfFame::ByYear
    else
      raise "not supported"
    end
  end

end
