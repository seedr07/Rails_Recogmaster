module CompaniesHelper
  def options_for_reset_interval(company)
    options = Company
      .reset_intervals
      .map { |key, value| [value.to_s.humanize, key]}
    options_for_select(options, company.reset_interval)
  end

end
