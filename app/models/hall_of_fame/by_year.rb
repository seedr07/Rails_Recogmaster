class HallOfFame::ByYear < HallOfFame::PeriodBase

  INTERVAL = Interval::YEARLY

  def label
    "#{I18n.t('datetime.prompts.year')} #{reference_time.year}"
  end
end