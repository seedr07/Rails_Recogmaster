class AddKioskModeKeyToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :kiosk_mode_key, :string
  end
end
