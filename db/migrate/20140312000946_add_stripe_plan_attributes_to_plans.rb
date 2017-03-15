class AddStripePlanAttributesToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :stripe_attributes, :text
  end
end
