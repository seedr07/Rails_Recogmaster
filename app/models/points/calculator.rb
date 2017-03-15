# For historical reasons, I'm leaving the main entry point to point calculation
# be through #update_total_points.  This method will also update the interval points

module Points
  module Calculator
    def self.included(base)
      base.send(:include, CommonMethods)
      base.send(:include, "Points::Calculator::#{base}Methods".constantize)
    end
  end
end