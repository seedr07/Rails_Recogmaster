RSpec::Matchers.define :have_many_through do |_association|
  
  match do |model|
    associations(model, :has_many, :through => true).any? { |a| a == _association }
  end

  failure_message_for_should do |model|
    error(
      :expected => [ "%s to have many through %s", model, _association ],
      :actual   => [ "%s has many through %s", model, associations(model, :has_many_through) ]
    )
  end
end