class TransitionRestrictedUsersToActive < ActiveRecord::Migration
  def up
    User.with_deleted.where(status: 'restricted').update_all("status='active'")
  end

  def down
  end
end
