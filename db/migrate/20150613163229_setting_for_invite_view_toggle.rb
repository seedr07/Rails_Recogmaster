class SettingForInviteViewToggle < ActiveRecord::Migration
  def up
    add_column :companies, :allow_invite, :boolean, default: true
  end

  def down

  end
end
