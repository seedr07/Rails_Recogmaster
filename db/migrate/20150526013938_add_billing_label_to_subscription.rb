class AddBillingLabelToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :billing_label, :string
  end
end
