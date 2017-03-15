class AddRoleToRoles < ActiveRecord::Migration
  def up
    Role.create :name => "system_user" rescue nil
  end
end
