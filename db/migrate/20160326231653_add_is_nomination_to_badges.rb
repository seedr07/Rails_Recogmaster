class AddIsNominationToBadges < ActiveRecord::Migration
  def change
    add_column :badges, :is_nomination, :boolean
  end
end
