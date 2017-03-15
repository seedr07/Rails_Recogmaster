RSpec::Matchers.define :validate_presence_of do |attribute|
  match do |model|
      model.class.validators.detect(Proc.new {false}) { |v| v.to_s.demodulize =~ /^PresenceValidator/ &&
          v.attributes.include?(attribute) }
  end

  failure_message_for_should do |model|
    "#{model.class} should validate the presence of #{attribute}"
  end  
end