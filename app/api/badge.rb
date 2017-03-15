module Api
  class Badge
    include Seahorse::Model

    type :badge do
      model ::Badge
      integer :id
      string :name, as: :short_name
      string :permalink
    end

    operation :show do

      input do
        integer :id
      end

      output :badge

    end
  end
end