class HallOfFame::ByWeek < HallOfFame::PeriodBase

  INTERVAL = Interval::WEEKLY

  def label
    "#{reset_interval_label_with_time(interval, reference_time)}"
  end
end