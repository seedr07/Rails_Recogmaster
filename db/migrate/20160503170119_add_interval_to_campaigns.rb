class AddIntervalToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :interval_id, :integer
  end
end
