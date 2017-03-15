class AddDeletedAtToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :deleted_at, :datetime
  end
end
