class AddStatusToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :status, :integer, default: Subscription::PENDING
    Subscription.all.each do |s|
      if s.quantity = 1
        s.update_column(:status, Subscription::CURRENT)
      else
        s.update_column(:status, Subscription::CANCELLED)
      end
    end
  end
end
