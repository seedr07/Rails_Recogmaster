class UpdateUsersCompanyName < ActiveRecord::Migration
  def up
    # DEPRECATED this migration since its served its purpose(migrated production data).
    #  - moved it to seeds for developer fresh installs
    # Company.where(domain: "users").first.update_attribute(:name, "")
  end

  def down
  end
end
