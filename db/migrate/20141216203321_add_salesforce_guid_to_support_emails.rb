class AddSalesforceGuidToSupportEmails < ActiveRecord::Migration
  def change
    add_column :support_emails, :salesforce_guid, :string
  end
end
