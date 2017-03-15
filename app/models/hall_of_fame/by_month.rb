class HallOfFame::ByMonth < HallOfFame::PeriodBase
  INTERVAL = Interval::MONTHLY

  def label
    "#{reset_interval_label(interval, reference_time)} #{reference_time.year}"
  end
end