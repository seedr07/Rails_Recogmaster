class AddAttributesToPlan < ActiveRecord::Migration
  def change
    add_column :plans, :amount, :decimal, :precision => 8, :scale => 2
    add_column :plans, :currency, :string, default: "USD"
    add_column :subscriptions, :currency, :string, default: "USD"
    change_column :subscriptions, :amount, :decimal, :precision => 8, :scale => 2
  end
end
