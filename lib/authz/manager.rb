module Authz
  class Manager
    def initialize(entity)
      @entity = entity
    end

    def can?(action, object)
      @entity.permissions.any? do |p|
        matching_permission?(action, object, p)
      end
    end

    def find(action, target_class)
      permissions = @entity.permissions.find_all do |p|
        (p.target_action == action.to_s) &&
            (p.target_class == target_class.to_s)
      end

      target_class.where("id in (?)", permissions.map(&:target_id))
    end

    def grant(action, object)
      return if can?(action, object)

      permission = Permission.find_or_create!(
          target_action: action,
          target_class: object.class.to_s,
          target_id: object.id
      )

      @entity.grant(permission)
    end

    def revoke(action, object)
      return unless can?(action, object)

      permission = @entity.permissions.find do |p|
        matching_permission?(action, object, p)
      end

      @entity.revoke(permission)
    end

    private

    def matching_permission?(action, object, permission)
      permission.target_class == object.class.to_s &&
          permission.target_action == action.to_s &&
          permission.target_id == object.id
    end
  end
end
