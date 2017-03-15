class CreateUserRoles < ActiveRecord::Migration
  def change
    create_table :user_roles do |t|
      t.integer :user_id
      t.integer :role_id

      t.timestamps
    end

    %w{Admin CompanyAdmin TeamLeader Employee}.each do |role|
      Role.create :name => role.underscore rescue nil
    end    
    
    if User.with_deleted.count > 0
      u = User.first
      u.roles << Role.admin
      u.roles << Role.company_admin      
    end
  end
end
