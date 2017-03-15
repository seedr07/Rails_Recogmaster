class Invoice
  attr_accessor :stripe_invoice

  def initialize(stripe_invoice)
    @stripe_invoice = stripe_invoice
  end

  def invoice
    stripe_invoice
  end

  def date
    Time.at(invoice.date).to_date
  end

  def amount_due
    invoice.amount_due / 100.0
  end
end