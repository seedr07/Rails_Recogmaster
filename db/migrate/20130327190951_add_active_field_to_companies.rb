class AddActiveFieldToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :disabled_at, :datetime
  end
end
