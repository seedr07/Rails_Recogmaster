class HallOfFame
  attr_reader :company, :user, :interval_code, :opts

  def self.whitelist
    # list to allow users to access hall of fame before enabling for
    # entire company
    ["bruce.rioch@metrobank.plc.uk.not.real.tld"]
  end

  def initialize(company, user, opts={})
    @company = company
    @user = user
    @interval_code = opts[:interval] || Interval::MONTHLY
    @opts = opts
  end

  def current_winners_grouped_by_period
    [
      winners_by_year,
      winners_by_quarter,
      winners_by_month,
      winners_by_week
    ]   
  end

  def winners_by_year
    time = opts[:time] || Time.now.last_year
    HallOfFame::ByYear.winners(company, user, time, opts)
  end

  def winners_by_quarter
    time = opts[:time] || Time.now.last_quarter
    HallOfFame::ByQuarter.winners(company, user, time, opts)
  end

  def winners_by_month
    time = opts[:time] || Time.now.last_month
    HallOfFame::ByMonth.winners(company, user, time, opts)
  end

  # Time.nowlast_week always go to the beginning of the week
  # which is not desirable because the diff between now and then > 1.week
  # and so we wont render "last week"
  def winners_by_week
    time = opts[:time] || (Time.now - 1.week)
    HallOfFame::ByWeek.winners(company, user, time, opts)
  end

  def by_badge
    company.company_badges.inject({}) do |hash, badge|
      Rails.logger.debug "[HALLOFFAME] HallOfFame#bybadge - Badge#{badge.id}"
      hash[badge] = HallOfFame::ByBadge.winners(company, user, badge, interval_code, opts)
      hash
    end
  end

  def by_team
    company.teams.inject({}) do |hash, team|
      Rails.logger.debug "[HALLOFFAME] HallOfFame#byteam - Team#{team.id}"
      hash[team] = HallOfFame::ByTeam.winners(company, user, team, interval_code, opts)
      hash
    end
  end

end