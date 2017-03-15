class CreateRewardsSettingsForCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :allow_rewards, :boolean, default: true
  end
end
