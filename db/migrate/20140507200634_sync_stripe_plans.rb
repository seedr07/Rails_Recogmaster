class SyncStripePlans < ActiveRecord::Migration
  def up
    unless Rails.env.test? or Rails.env.development?
      Plan.reset_column_information
      Plan.sync!
      end
  end

  def down
  end
end
