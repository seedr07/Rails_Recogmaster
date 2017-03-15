class AddDeletedAtToBadges < ActiveRecord::Migration
  def change
    add_column :badges, :deleted_at, :datetime
  end
end
