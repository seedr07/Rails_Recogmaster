class Report::Badge
  attr_reader :object, :start_time, :end_time

  # object can be user, team, or company
  # as long as it can be a recipient of a recognition
  def initialize(object, start_time=50.years.ago, end_time=Time.now)
    @object = object
    @start_time = start_time
    @end_time = end_time
  end

  def company
    # for some reason, object.kind_of?(Company) doesn't work
    @company ||= (object.respond_to?(:company) ? object.company : object)
  end

  def data
    @data ||= raw_data.group_by(&:badge)
  end

  def data_by_date
    @data_by_date ||= raw_data.group_by(&:timestamp)
  end

  def badges
    @badges ||= company.badges
  end

  def dates
    raw_data.group_by(&:time).keys
  end

  private
  def raw_data
    @raw_data ||= query.map do |row|
      time = Date.commercial(*GraphData.split_yearweek(row.week), -1).to_time + 1.day # adjust from sunday to monday

      # need to account for multiple recipient recognitions
      # and subtract them from count
      recognition_ids = row.recognition_ids.split(",")
      dupes = recognition_ids.length - recognition_ids.uniq.length

      OpenStruct.new(
        week: row.week, 
        time: time, 
        timestamp: time.to_i*1000,
        badge: Badge.cached(row.badge_id), 
        count: row.count - dupes
      )
    end
  end

  def query
    RecognitionRecipient
      .joins(:recognition)
      .where(recipient_company_id: company.id)
      .where("recognitions.created_at >= ? AND recognitions.created_at <= ?", start_time, end_time)
      .select("distinct YEARWEEK(CONVERT_TZ(recognitions.created_at, '+00:00', '-08:00'), 5) as week, group_concat(recognitions.id) as recognition_ids, recognitions.badge_id as badge_id, count(recognitions.badge_id) as count")
      .group("YEARWEEK(CONVERT_TZ(recognitions.created_at, '+00:00', '-08:00'), 5), recognitions.badge_id")
  end

end