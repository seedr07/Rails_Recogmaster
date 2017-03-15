module Twilio
  class PhoneNumber
    attr_reader :number

    # type => [:phone_number, :national_format, :country_code, :url]
    def self.format(number, type = :phone_number)
      return nil unless Recognize::Application.twilio_client.sid.present?
      
      response = Recognize::Application.twilio_client.lookup.phone_numbers.get(number)
      return response.send(type)
    rescue => e
      if e.try(:code) && e.code == 20404
        return nil
      else
        raise e
      end
    end

    def initialize(raw_number)
      @raw_number = raw_number
    end

    def number
      @raw_number
    end

    def twilio
      "+1#{number}" unless number.start_with?("+1")
    end

    def standard
      number.gsub(/^\+1/, '')
    end
  end
end