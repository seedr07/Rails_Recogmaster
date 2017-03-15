class AddFieldsToRewards < ActiveRecord::Migration
  def change
    add_column :rewards, :recipient_id, :integer
    add_column :rewards, :sent_at, :datetime
    add_column :rewards, :amount, :decimal
    remove_column :rewards, :status
  end
end
