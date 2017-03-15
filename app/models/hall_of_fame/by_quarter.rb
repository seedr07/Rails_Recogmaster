class HallOfFame::ByQuarter < HallOfFame::PeriodBase

  INTERVAL = Interval::QUARTERLY

  def label
    reset_interval_label(interval, reference_time)+" #{reference_time.year}"
  end
end