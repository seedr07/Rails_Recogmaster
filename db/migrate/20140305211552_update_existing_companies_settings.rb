class UpdateExistingCompaniesSettings < ActiveRecord::Migration
  def up
    Company.update_all("allow_posting_to_yammer_wall=1")
  end

  def down
  end
end
