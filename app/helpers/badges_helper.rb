module BadgesHelper
  def selected_badge_roles(badge)
    badge.roles_with_permission(:send).map(&:id)
  end
end
