module EmailBlastHelper
  def blast_template_heading 
    @company_report.interval.yearly? ?
      yearly_template_heading : 
      default_template_heading
  end

  private
  def default_template_heading
    [
      @company_report.company.name.humanize,
      reset_interval_adverb(@interval).capitalize,
      "Recognition Summary"
    ].join(" ")
  end

  def yearly_template_heading
    year = @company_report.from.year
    "#{@company_report.company.name.humanize} #{year} Year In Review"
  end
end