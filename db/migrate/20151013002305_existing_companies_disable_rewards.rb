class ExistingCompaniesDisableRewards < ActiveRecord::Migration
  def change
    Company.update_all(allow_rewards: false)
  end
end
