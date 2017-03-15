class Interval

  # TODO PETER HELP ME!
  # RESET_INTERVALS = {
  #   DAILY=0 => t("dict.daily"),
  #   WEEKLY=1 => t("dict.weekly"),
  #   MONTHLY=2 => t("dict.monthly"),
  #   QUARTERLY=3 => t("dict.quarterly"),
  #   YEARLY=4 => t("dict.yearly")
  # }

  RESET_INTERVALS = {
    DAILY=0 => "Daily",
    WEEKLY=1 => "Weekly",
    MONTHLY=2 => "Monthly",
    QUARTERLY=3 => "Quarterly",
    YEARLY=4 => 'Yearly'
  }  

  RESET_INTERVALS_WITH_NULL = RESET_INTERVALS.merge({
    NULL=nil => "Null"  
  })

  CUSTOM = -1
  attr_reader :interval, :interval_code

  def initialize(interval_code)
    @interval_code = interval_code.nil? ? nil : interval_code.to_i
  end

  def ==(other)
    other.interval_code == self.interval_code
  end

  def to_i
    interval_code
  end

  def interval
    RESET_INTERVALS[interval_code]
  end

  def custom?
    interval_code == CUSTOM
  end

  def daily?
    interval_code == DAILY
  end

  def weekly?
    interval_code == WEEKLY
  end

  def monthly?
    interval_code == MONTHLY
  end

  def quarterly?
    interval_code == QUARTERLY
  end

  def yearly?
    interval_code == YEARLY
  end

  def null?
    interval_code == NULL
  end

  def shift(opts={})
    time = opts[:time] || Time.now
    shift_by = opts[:shift] || 0
    case
    when daily?
      time + shift_by.days
    when weekly?
      time + shift_by.weeks
    when monthly?
      time + shift_by.months
    when quarterly?
      time + (3 * shift_by).months
    when yearly?
      time + shift_by.years
    end
  end

  def start(opts={})
    start_or_end("beginning", opts)
  end

  def end(opts={})
    start_or_end("end", opts)
  end

  def start_or_end(which, opts={})
    opts[:time] ||= Time.now
    time = shift(opts)
    case 
    when daily?
      time.send("#{which}_of_day")
    when weekly?
      time.send("#{which}_of_week")
    when monthly?
      time.send("#{which}_of_month")
    when quarterly?
      time.send("#{which}_of_quarter")
    when yearly?
      time.send("#{which}_of_year")
    end
  end

  class << self
    def daily
      Interval.new(Interval::DAILY)
    end

    def weekly
      Interval.new(Interval::WEEKLY)
    end

    def monthly
      Interval.new(Interval::MONTHLY)
    end

    def quarterly
      Interval.new(Interval::QUARTERLY)
    end

    def yearly
      Interval.new(Interval::YEARLY)
    end

    def null
      Interval.new(Interval::NULL)
    end

    def custom
      Interval.new(Interval::CUSTOM)
    end
  end
end