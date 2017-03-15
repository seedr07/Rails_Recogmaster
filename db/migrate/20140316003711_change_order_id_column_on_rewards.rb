class ChangeOrderIdColumnOnRewards < ActiveRecord::Migration
  def up
    change_column :rewards, :order_id, :string
  end

  def down
  end
end
