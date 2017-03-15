class Plan
  class Creator
    include Common

    def self.create!(subscription)
      new(subscription).create!
    end

    def create!
      transaction do
        response = Stripe::Plan.create(plan_attributes)
        @plan = Plan.sync_plan!(response)
      end
      return @plan
    end

  end
end