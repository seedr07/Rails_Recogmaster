module UserAnalytics
  def activated?(threshold = 1)
    self.sent_recognitions.size >= threshold
  end
  
  def engaged?(time_threshold = 1.week.ago, recognition_threshold = 1)
    self.sent_recognitions.where("created_at > ?", time_threshold).size > recognition_threshold
  end
   
end