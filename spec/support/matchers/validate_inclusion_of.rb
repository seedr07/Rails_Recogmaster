RSpec::Matchers.define :validate_inclusion_of do |attribute, opts|
  match do |model|
      model.class.validators.detect(Proc.new {false}) { |v| v.to_s.demodulize =~ /^InclusionValidator/ &&
          v.attributes.include?(attribute) and v.options == opts}
  end

  failure_message_for_should do |model|
    "#{model.class} should validate the presence of #{attribute}"
  end  
end