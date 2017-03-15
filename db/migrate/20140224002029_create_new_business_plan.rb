class CreateNewBusinessPlan < ActiveRecord::Migration
  def up
    change_column :plans, :price_per_user, :decimal, precision: 10, scale: 2
    change_column :subscriptions, :unit_price, :decimal, precision: 10, scale: 2
    FactoryGirl.create(:business_0795_monthly_plan)
  end

  def down
    change_column :plans, :price_per_user, :decimal
    change_column :subscriptions, :unit_price, :decimal
    Plan.where(name: "business795monthly").destroy_all
  end
end
