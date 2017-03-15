class CleanupProductionData < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.execute("update companies set disabled_at = NULL;")
    ActiveRecord::Base.connection.execute("update users inner join user_roles on users.id = user_roles.user_id set status='active' where user_roles.role_id=2 AND users.status='pending_signup_completion' AND users.verified_at IS NOT NULL;")
  end

  def down
  end
end
