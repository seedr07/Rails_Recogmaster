class MakeBadgeNominationFalseDefault < ActiveRecord::Migration
  def up
    change_column :badges, :is_nomination, :boolean, default: false
  end

  def down
    change_column :badges, :is_nomination, :boolean, default: nil
  end
end
