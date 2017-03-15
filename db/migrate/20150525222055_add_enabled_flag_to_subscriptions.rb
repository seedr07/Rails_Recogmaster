class AddEnabledFlagToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :enabled, :boolean, default: true
    Subscription.where.not(quantity: nil).update_all("enabled=true")
  end
end
