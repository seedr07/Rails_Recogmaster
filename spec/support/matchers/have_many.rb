RSpec::Matchers.define :have_many do |_association, opts|

  if opts and opts[:through]
    match do |model|
      associations(model, :has_many, opts).any? { |a| a == _association }
    end

    failure_message_for_should do |model|
      error(
        :expected => [ "%s to have many %s through %s", model, _association, opts[:through] ],
        :actual   => [ "%s has many %s ", model, associations(model, :has_many) ]
      )
    end

  else
    match do |model|
      associations(model, :has_many).any? { |a| a == _association }
    end

    failure_message_for_should do |model|
      error(
        :expected => [ "%s to have many %s", model, _association ],
        :actual   => [ "%s has many %s", model, associations(model, :has_many) ]
      )
    end
  end
end