class AddCustomBadgesEnabledFlagToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :custom_badges_enabled_at, :datetime
  end
end
