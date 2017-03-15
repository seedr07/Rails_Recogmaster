class Points::Resetter

  def self.run_scheduler
    time = Time.now

    # Mondays
    Points::Resetter.reset_weekly! if time.wday == 1

    # First day of month
    Points::Resetter.reset_monthly! if time.day == 1

    # First day of quarter
    Points::Resetter.reset_quarterly! if time.to_date == time.beginning_of_quarter.to_date
  end

  def self.reset_weekly!
    new(Company.where(reset_interval: Interval::WEEKLY)).reset!
  end

  def self.reset_monthly!
    new(Company.where(reset_interval: Interval::MONTHLY)).reset!
  end

  def self.reset_quarterly!
    new(Company.where(reset_interval: Interval::QUARTERLY)).reset!
  end

  attr_reader :companies

  def initialize(companies)
    @companies = Array(companies)
  end

  def reset!
    companies.each do |company|
      reset_company(company)
    end
  end

  private
  def reset_company(company)
    company.users.each do |user|
      reset_user(user)
    end

    company.teams.each do |team|
      reset_team(team)
    end
  end

  def reset_user(user)
    report = Report::User.new(user, user.interval_start_date, Time.now)
    user.update_column(:interval_points, report.points)
  end

  def reset_team(team)
    report = Report::Team.new(team, team.interval_start_date, Time.now)
    team.update_column(:interval_team_points, report.team_points)
    team.update_column(:interval_member_points, report.member_points)
  end
end
