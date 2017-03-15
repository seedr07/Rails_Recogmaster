RSpec::Matchers.define :validate_format_of do |attribute, opts|
  match do |model|
    options = opts || {}
      v = validator(model, attribute)
      v.options == options
  end

  failure_message_for_should do |model|
    "#{model.class} should validate the format of #{attribute} #{options_message(model, attribute)}"
  end  
  
  def validator(model, attribute)
    model.class.validators.detect(Proc.new {false}) {|v| v.to_s.demodulize =~ /^FormatValidator/ && v.attributes.include?(attribute)}
  end
  
  def options_message(model, attribute)
    v = validator(model, attribute)
    v.options.blank? ? "" : "but validates with #{v.options}"
  end
end