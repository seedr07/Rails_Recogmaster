class AddCompanyIdToRecognitions < ActiveRecord::Migration
  def up
    add_column :recognitions, :company_id, :integer

    #hack for sample data, in case there are any existing user records that dont have a company
    #(this is because the codebase at this point has a bug where you create users without a company)
    #(and thus has introduced sample data users without a company_id)
    User.with_deleted.update_all("company_id = 1") rescue nil

    Recognition.with_deleted.all.each do |r|
      r.update_attribute(:company_id, r.sender.company_id) rescue nil
    end
  end
  def down
    remove_column :recognitions, :company_id
  end
end
