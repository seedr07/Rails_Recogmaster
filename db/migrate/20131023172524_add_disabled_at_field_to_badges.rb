class AddDisabledAtFieldToBadges < ActiveRecord::Migration
  def change
    add_column :badges, :disabled_at, :datetime
  end
end
