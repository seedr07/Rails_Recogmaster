class ResCalculator

  attr_reader :object

  def initialize(object)
    @object = object
  end

  def report
    @report ||=  report_class.new(object, 1.month.ago, Time.now)

  end

  # metro benchmark: 6.98 seconds 5/1/2014
  # new metro bench: 0.27 seconds 5/1/2014
  def res_score
    return 0 if report.users.size == 0
    ((report.unique_recipient_count / report.users.size.to_f) * 100).round(2)
  end

  private
  # can work for Team or Company or anything else as long as it 
  # has a report and can respond to #unique_recognition_recipients and #users
  def report_class
    "Report::#{object.class}".constantize
  end
end
