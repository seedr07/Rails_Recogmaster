class AddSalesforceGuidToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :salesforce_guid, :text
  end
end
