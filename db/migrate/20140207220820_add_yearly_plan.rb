class AddYearlyPlan < ActiveRecord::Migration
  def up
    FactoryGirl.create(:business_100_yearly_plan)
  end

  def down
    Plan.where(name: :business100Yearly).destroy_all
  end
end
