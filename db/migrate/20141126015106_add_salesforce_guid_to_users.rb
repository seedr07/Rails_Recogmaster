class AddSalesforceGuidToUsers < ActiveRecord::Migration
  def change
    add_column :users, :salesforce_guid, :string
  end
end
