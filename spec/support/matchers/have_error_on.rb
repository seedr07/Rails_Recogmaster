RSpec::Matchers.define :have_errors_on do |attribute|
  match do |model|
    model.valid? # call it here so we don’t have to write it in before blocks
    model.errors.key?(attribute)
  end
end