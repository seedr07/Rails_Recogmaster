class AddSettingForAllowHallOfFame < ActiveRecord::Migration
  def change
    add_column :companies, :allow_hall_of_fame, :boolean, default: false
  end
end
