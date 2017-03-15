module RecognitionConcern
  module Display
    extend ActiveSupport::Concern

    def permalink(opts={})
      url = recognition_url(self, host: Recognize::Application.config.host, protocol: Recognize::Application.config.web_protocol)
      if opts[:include_www] && Recognize::Application.config.host == "recognizeapp.com"
        url.gsub!('https://recognizeapp.com', 'https://www.recognizeapp.com') 
      end
      url
    end

    def badge_permalink(size=200, protocol="")
      self.badge.permalink(size, protocol)
    end
    
    def badge_name
      self.badge.short_name
    end

    def system_recognition?
      self.badge.system?
    end
    
    def recipients_label
      self.flattened_recipients.collect{|r| r.full_name}.to_sentence
    end

  end
end