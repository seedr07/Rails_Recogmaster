class LineItem < ActiveRecord::Base
  belongs_to :company, inverse_of: :line_items
  belongs_to :subscription, inverse_of: :line_items

  validates :company_id, :amount, :description, presence: true

  scope :unbilled, ->{ where(stripe_invoice_id: nil) }

  serialize :stripe_attributes

  def self.create_invoice_items_for_customer!(subscription, customer)
    return subscription.line_items.map do |item|
      item.create_invoice_item_for_customer!(subscription, customer)
    end
  end

  def create_invoice_item_for_customer!(subscription, customer)
    response = Stripe::InvoiceItem.create(
      customer: customer.id,
      amount: (self.amount*100).to_i,
      currency: self.currency,
      description: self.description
    )

    update_column(:stripe_invoice_id, response.invoice)
    update_attribute(:stripe_attributes, response.to_hash)
    return response
  end

  def status
    stripe_invoice_id.present? ? "PAID" : "PENDING"
  end
end
