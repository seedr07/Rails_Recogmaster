# Remove when the below pull request has been merged and can be bundled
# https://github.com/stripe/stripe-ruby/pull/122
module Stripe
  class StripeObject
    def respond_to_missing?(symbol, include_private = false)
      @values && @values.has_key?(symbol) || super
    end    
  end
end