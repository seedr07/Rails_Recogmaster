module Api
  module V2
    module Authorization
      UnauthorizedException = Class.new(StandardError)

      def self.extended(base)
        base.send(:helpers, Helpers)
      end

      def object(&block)
        route_setting :object, block
      end

      def authorize(&block)
        before do 
          raise UnauthorizedException, "You do not have permission to access this resource" unless instance_eval &block
        end
      end

      module Helpers
        def object
          @object ||= self.instance_eval(&route_setting(:object))
        end
      end
    end
  end
end