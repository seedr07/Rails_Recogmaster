class AddAchievementToBadges < ActiveRecord::Migration
  def change
    add_column :badges, :is_achievement, :boolean, default: false
    add_column :badges, :achievement_frequency, :integer, default: 10
    add_column :badges, :achievement_interval_id, :integer, default: Interval::QUARTERLY
  end
end
