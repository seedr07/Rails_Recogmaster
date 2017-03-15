module Api
  module V2
    class InvalidHeaderResponse < Doorkeeper::OAuth::ErrorResponse
      def initialize(detail_key)
        super(name: detail_key)
      end
    end
  end
end