class CreateBusinessYearlyPlan4680 < ActiveRecord::Migration
  def up
    Plan.where(name: "business395yearly").destroy_all
    FactoryGirl.create(:business_4680_yearly_plan)
  end

  def down
    Plan.where(name: "business4680yearly").destroy_all
  end
end
