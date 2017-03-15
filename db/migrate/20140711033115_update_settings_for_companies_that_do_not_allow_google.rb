class UpdateSettingsForCompaniesThatDoNotAllowGoogle < ActiveRecord::Migration
  def up
    Company.where(allow_google_login: false).each do |c|
      c.update_attribute(:allow_google_contact_import, false)
    end
  end
end
