class AddIsInstantFlagToBadges < ActiveRecord::Migration
  def change
    add_column :badges, :is_instant, :boolean, default: false
  end
end
