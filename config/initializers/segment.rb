segment_creds = Rails.configuration.credentials['segment']

if segment_creds["write_key"].present?
  Analytics = Segment::Analytics.new({
      write_key: segment_creds['write_key'],
      on_error: Proc.new { |status, msg| print msg }
  })
end
