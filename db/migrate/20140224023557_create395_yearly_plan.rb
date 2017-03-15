class Create395YearlyPlan < ActiveRecord::Migration
  def up
    FactoryGirl.create(:business_0395_yearly_plan)
    Plan.where(name: "business2400Yearly").first.update_attribute(:is_public, false)
  end

  def down
    Plan.where(name: "business395yearly").destroy_all
  end
end
