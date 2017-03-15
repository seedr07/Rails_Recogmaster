class EnsureAllUsersHaveRoles < ActiveRecord::Migration
  def up
    User.with_deleted.all.select{|u| u.roles.blank?}.each{|u| u.roles << Role.employee}
  end
end
