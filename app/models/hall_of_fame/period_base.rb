class HallOfFame::PeriodBase
  include IntervalHelper

  attr_accessor :company, :user, :reference_time, :opts, :sort_by

  def self.winners(company, user, reference_time, opts={})
    new(company, user, reference_time, opts).winners
  end

  def initialize(company, user, reference_time, opts)
    @company = company
    @user = user
    @reference_time = reference_time
    @opts = opts
    @sort_by  = opts[:sort_by] || :points
  end

  def interval
    Interval.new(self.class.const_get("INTERVAL"))
  end

  def start_time
    interval.start(time: reference_time)
  end

  def end_time
    interval.end(time: reference_time)
  end

  def winners
    key = "HallOfFame-#{company.id}-#{user.id}-#{start_time.to_date.to_s}-#{end_time.to_date.to_s}-#{opts[:badge_id]}-#{opts[:team_id]}"
    Rails.cache.fetch(key) do
      Rails.logger.debug "[HALLOFFAME] #{self.class}#winners - #{key}"

      report = Report::Company.new(company, start_time, end_time, badge_id: opts[:badge_id], team_id: opts[:team_id], points_only: true)
      HallOfFame::Group.new(self.label, report)
    end
  end
end