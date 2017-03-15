class AddStripeInvoiceIdToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :stripe_invoice_id, :string
  end
end
