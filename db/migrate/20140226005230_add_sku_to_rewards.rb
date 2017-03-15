class AddSkuToRewards < ActiveRecord::Migration
  def change
    add_column :rewards, :sku, :text
    add_column :rewards, :status, :string, default: "funded"
  end
end
