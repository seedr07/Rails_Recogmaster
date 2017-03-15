class Teams::MemberUpdater < Teams::BaseUpdater
  def remove_users
    team.users.each do |user|
      team.remove_member(user) unless requests_to_add_member?(user)
    end
  end

  def add_users
    people.each do |user|
      team.add_member(user) unless already_has_member?(user)
    end
  end

  def has_person?(user)
    team.users.include?(user)
  end

  private
  def already_has_member?(user)
    team.users.include?(user)
  end

  def requests_to_add_member?(user)
    people.include?(user)
  end

  def after_save
    team.update_all_points!
  end
end