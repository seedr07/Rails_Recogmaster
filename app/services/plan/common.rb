class Plan
  module Common
    extend ActiveSupport::Concern

    included do
      include ActionView::Helpers::NumberHelper
      include ActiveRecordTransaction
      attr_reader :subscription, :plan
    end

    def initialize(subscription)
      @subscription = subscription
    end

    def plan_id
      subscription.stripe_plan_id
    end

    def amount
      subscription.amount
    end

    def amount_in_cents
      amount.present? ? (amount * 100).to_i : 0
    end

    def currency
      subscription.currency
    end

    def label
      subscription.billing_label 
    end

    def interval
      subscription.charge_interval.gsub(/ly$/, '').downcase
    end

    def statement_descriptor
      "Recognize"
    end

    def plan_attributes
      {
        id: plan_id, 
        amount: amount_in_cents,
        currency: currency,
        interval: interval,
        name: label,
        statement_descriptor: statement_descriptor        
      }
    end
  end
end