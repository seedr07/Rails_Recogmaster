class AddSettingForCompanyToDisableInstantRecognition < ActiveRecord::Migration
  def change
    add_column :companies, :allow_instant_recognition, :boolean, default: true
  end
end
