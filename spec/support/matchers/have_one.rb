RSpec::Matchers.define :have_one do |_association|
  
  match do |model|
    associations(model, :has_one).any? { |a| a == _association }
  end

  failure_message_for_should do |model|
    error(
      :expected => [ "%s to have one %s", model, _association ],
      :actual   => [ "%s has one %s", model, associations(model, :has_one) ]
    )
  end
end