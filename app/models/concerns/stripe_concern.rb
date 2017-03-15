module StripeConcern

  def stripe_plan_id
    # If the additional formats for dev/test changes,
    # be sure to update Plan#domain_from_stripe_plan_id
    uid = "#{self.company.domain}"
    uid = uid+"[dev]("+`echo \`hostname\``.strip+")" if Rails.env.development?
    uid = uid+"[test]" if Rails.env.test?
    return uid
  end

  def next_stripe_invoice
    Invoice.new(Stripe::Invoice.upcoming(customer: customer)) rescue nil
  end  

  def stripe_invoices
    Stripe::Invoice.all(customer: customer, count: 100).collect{|i| Invoice.new(i)}
  end

  def stripe_customer
    Stripe::Customer.retrieve(stripe_customer_token) if using_stripe?
  end

  def stripe_subscriptions
    stripe_customer.subscriptions.data if using_stripe?
  end

  def active_stripe_subscription?
    stripe_subscriptions.present?
  end

  def using_stripe?
    stripe_customer_token.present?
  end

end