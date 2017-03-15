class AddCompanyAndNetworkToRecognitionRecipients < ActiveRecord::Migration
  def change
    add_column :recognition_recipients, :recipient_company_id, :integer
    add_column :recognition_recipients, :recipient_network, :string
  end
end
