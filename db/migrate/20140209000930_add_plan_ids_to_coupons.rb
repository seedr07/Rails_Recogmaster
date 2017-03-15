class AddPlanIdsToCoupons < ActiveRecord::Migration
  def change
    add_column :coupons, :plan_ids, :text
  end
end
