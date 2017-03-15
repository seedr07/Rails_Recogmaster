class AddDisableSignupSettingToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :disable_signups, :boolean, default: false
  end
end
