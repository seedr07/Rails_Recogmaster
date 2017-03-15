class Teams::ManagerUpdater < Teams::BaseUpdater
  def remove_users
    team.team_managers.each do |tm|
      user = tm.manager
      team.remove_managers(user) unless requests_to_add_manager?(user)
    end
  end

  def add_users
    people.each do |user|
      team.add_managers(user) unless already_has_manager?(user)
    end
  end

  def has_person?(user)
    team.team_managers.map(&:manager_id).include?(user.id)
  end

  private
  def already_has_manager?(user)
    team.team_managers.include?(user)
  end

  def requests_to_add_manager?(user)
    people.include?(user)
  end
end