class AddIntervalToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :charge_interval, :string
  end
end
