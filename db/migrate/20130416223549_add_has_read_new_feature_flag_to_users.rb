class AddHasReadNewFeatureFlagToUsers < ActiveRecord::Migration
  def change
    add_column :users, :has_read_features, :text
  end
end
