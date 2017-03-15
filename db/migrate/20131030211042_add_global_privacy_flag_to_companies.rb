class AddGlobalPrivacyFlagToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :global_privacy, :boolean, default: false
  end
end
