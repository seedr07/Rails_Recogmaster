module Authz
  module PermissionsHelper
    def grant_permission_to_roles(action, new_roles)
      curr_roles = roles_with_permission(action)
      # clean up all permissions for this badge, before re-adding
      curr_roles.each do |role|
        Authz::Manager.new(role).revoke(action, self)
      end

      new_roles.each do |role|
        Authz::Manager.new(role).grant(action, self)
      end
    end

    def roles_with_permission(action)
      permission = Permission.find_by(
          target_class: self.class.to_s,
          target_id: self.id,
          target_action: action.to_s
      )

      return [] if permission.nil?

      ids = permission.company_roles.ids
      self.company.company_roles.find(ids)
    end
  end
end
