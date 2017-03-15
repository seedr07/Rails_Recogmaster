class ChangeInvoiceDateColumnOnSubscriptions < ActiveRecord::Migration
  def change
    rename_column :subscriptions, :invoice_date, :billing_start_date
  end
end
