class AddCompanyIdToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :company_id, :integer
  end
end
