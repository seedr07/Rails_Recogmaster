class AddNominationSettingToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :allow_nominations, :boolean, default: false
  end
end
