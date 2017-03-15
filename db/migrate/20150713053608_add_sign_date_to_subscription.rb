class AddSignDateToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :sign_date, :date
  end
end
