module Recognize
  class Application

    class TwilioMockClient
      def lookup
        self
      end

      def phone_numbers
        self
      end

      def get(number)
        if number.match(/[a-zA-Z]/)
          number = nil
        elsif number.match(/^\+/)
          number = number.gsub(/[-()\s]/,'')
        else
          number = "+#{number.gsub(/[-()\s]/,'')}"
        end
        Hashie::Mash.new phone_number: number
      end

      def method_missing(*args, &block)
        return true
      end
    end

    def twilio_client
      return TwilioMockClient.new unless Recognize::Application.config.credentials.has_key?("twilio")
      Twilio::Client.new(
        Recognize::Application.config.credentials["twilio"]["sid"],
        Recognize::Application.config.credentials["twilio"]["token"],
        Recognize::Application.config.credentials["twilio"]["number"]
      )
    end

    def twilio_test_client
      return TwilioMockClient.new unless Recognize::Application.config.credentials.has_key?("twilio-test")
      Twilio::Client.new(
        Recognize::Application.config.credentials["twilio-test"]["sid"],
        Recognize::Application.config.credentials["twilio-test"]["token"],
        Recognize::Application.config.credentials["twilio-test"]["number"]
      )
    end
  end
end
