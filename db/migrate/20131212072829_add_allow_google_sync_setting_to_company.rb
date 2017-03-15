class AddAllowGoogleSyncSettingToCompany < ActiveRecord::Migration
  def up
    add_column :companies, :allow_google_sync, :boolean, default: true
    Company.reset_column_information
    Company.where("domain like '%MS-Spain-Sales%'").update_all("allow_google_sync = false")
  end
  
  def down
    remove_column :companies, :allow_google_sync
  end
end
