RSpec::Matchers.define :have_and_belong_to_many do |_association|
  
  match do |model|
    associations(model, :has_and_belongs_to_many).any? { |a| a == _association }
  end

  failure_message_for_should do |model|
    error(
      :expected => [ "%s to have and belong to many %s", model, _association ],
      :actual   => [ "%s has and belongs to many %s", model, associations(model, :has_and_belongs_to_many) ]
    )
  end
end