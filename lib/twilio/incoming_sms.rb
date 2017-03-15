 # {"ToCountry"=>"US",
 # "ToState"=>"CA",
 # "SmsMessageSid"=>"SMe09f533bfd99fbfb5dc2d9fe54b63dc4",
 # "NumMedia"=>"0",
 # "ToCity"=>"NOVATO",
 # "FromZip"=>"15214",
 # "SmsSid"=>"SMe09f533bfd99fbfb5dc2d9fe54b63dc4",
 # "FromState"=>"PA",
 # "SmsStatus"=>"received",
 # "FromCity"=>"PITTSBURGH",
 # "Body"=>"Test.",
 # "FromCountry"=>"US",
 # "To"=>"+1231231234",
 # "ToZip"=>"94949",
 # "MessageSid"=>"SMe09f533bfd99fbfb5dc2d9fe54b63dc4",
 # "AccountSid"=>"AC0edc3c1377648823c6e836e36dc57979",
 # "From"=>"+1231231234",
 # "ApiVersion"=>"2010-04-01",
 # "controller"=>"twilio",
 # "action"=>"sms_reply"}

module Twilio
  class IncomingSms
    attr_reader :params

    def initialize(params)
      @params = params
    end

    def body
      params["Body"]
    end

    def from
      PhoneNumber.new(params["From"]).standard
    end
  end
end