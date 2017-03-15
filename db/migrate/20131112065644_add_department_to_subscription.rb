class AddDepartmentToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :department, :text
  end
end
