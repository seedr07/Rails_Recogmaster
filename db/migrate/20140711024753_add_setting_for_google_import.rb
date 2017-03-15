class AddSettingForGoogleImport < ActiveRecord::Migration
  def change
    rename_column :companies, :allow_google_sync, :allow_google_login
    add_column :companies, :allow_google_contact_import, :boolean, default: true
  end
end
