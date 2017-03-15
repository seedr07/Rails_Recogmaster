class AddAchievementsSettingToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :allow_achievements, :boolean, :default => false
  end
end
