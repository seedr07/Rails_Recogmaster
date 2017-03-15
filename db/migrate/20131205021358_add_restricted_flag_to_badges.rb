class AddRestrictedFlagToBadges < ActiveRecord::Migration
  def change
    add_column :badges, :restricted, :boolean, default: false
  end
end
