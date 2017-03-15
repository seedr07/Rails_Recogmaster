class AddSendingLimitFieldsToBadges < ActiveRecord::Migration
  def change
    add_column :badges, :sending_frequency, :integer
    add_column :badges, :sending_interval_id, :integer
  end
end
