module Points
  module Calculator
    module CommonMethods
      extend ActiveSupport::Concern

      included do
        scope :restricted_to_interval, ->(reset_interval) {  where("created_at > ?", interval_start_date(reset_interval)) }  
      end

      module ClassMethods
        def interval_start_date(reset_interval, opts={})
          reset_interval = Interval.new(reset_interval) unless reset_interval.kind_of?(Interval)
          reset_interval.start(opts)         
        end

        def interval_end_date(reset_interval, opts={})
          reset_interval = Interval.new(reset_interval) unless reset_interval.kind_of?(Interval)
          reset_interval.end(opts)         
        end

      end

      def interval_start_date(opts={})
        self.class.interval_start_date(reset_interval, opts)
      end

      def interval_end_date(opts={})
        self.class.interval_end_date(reset_interval, opts)
      end

      def reset_interval
        c = self.respond_to?(:company) ? self.company : self.sender_company # quick hack to make this work for Recognition class
        Interval.new(c.reset_interval)
      end

    end
  end
end