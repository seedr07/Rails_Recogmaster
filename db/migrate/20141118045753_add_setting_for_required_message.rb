class AddSettingForRequiredMessage < ActiveRecord::Migration
  def change
    add_column :companies, :message_is_required, :boolean, default: false
  end
end
