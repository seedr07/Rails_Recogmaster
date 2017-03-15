class Recognize::Application
  cattr_accessor :hasher
  self.hasher = Hashids.new("3b27ad4b9db46c5727c3431a21a43c79ba2286c06222e20a3c4edf9227659502141df988d9f47edddda7420ce2d04b9076bedbaf0524096afd6b284aaea3914b", 8)
end

class ActiveRecord::Base
  include HashIdConcern
end