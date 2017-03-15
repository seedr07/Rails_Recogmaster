RSpec::Matchers.define :save do |attribute|
  match do |model|
    model.save.should be_true
  end
end