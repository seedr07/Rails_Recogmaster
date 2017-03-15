class AddIntervalFrequencyToRewards < ActiveRecord::Migration
  def change
    add_column :rewards, :frequency, :integer
    add_column :rewards, :interval_id, :integer
  end
end
