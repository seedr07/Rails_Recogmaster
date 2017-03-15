class AddParentCompanyIdToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :parent_company_id, :integer
  end
end
