RSpec::Matchers.define :belong_to do |_association|
  
  match do |model|
    associations(model, :belongs_to).any? { |a| a == _association }
  end

  failure_message_for_should do |model|
    error_str(
      :expected => [ "%s to belong to %s", model, _association ],
      :actual   => [ "%s belongs to %s", model, associations(model, :belongs_to) ]
    )
  end


end