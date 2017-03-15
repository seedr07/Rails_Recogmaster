class Plan
  class Updater
    include Common
    def self.update!(subscription)
      new(subscription).update!
    end

    def update!
      # you cannot edit stripe plans, so strategy is to delete
      # and recreate if amounts need to be changed
      transaction do
        plan = Stripe::Plan.retrieve(plan_id)
        plan.delete
        plan = Plan::Creator.create!(subscription)
        # TBD: - change subscription to point to the new plan
        return plan
      end       
    end
  end
end