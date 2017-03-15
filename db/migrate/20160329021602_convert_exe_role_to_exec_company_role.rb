class ConvertExeRoleToExecCompanyRole < ActiveRecord::Migration

  def up
    CompanyRole.where(name: "Executive").each do |role|
      role.destroy
    end

    Company.includes(:company_roles).to_a.each do |company|
      company.company_roles.create!(name: "Executive")
    end

    User.includes(:user_roles).to_a.each do |user|
      if user.roles.map(&:id).include?(Role.executive.id)
        executive_role = user.company.company_roles.find_by(name: "Executive")
        user.company_roles.add(executive_role)
      end
    end

    UserRole.where(role_id: Role.executive.id).each(&:destroy)

    Badge.where(restricted: true).to_a.each do |badge|
      company = badge.company
      roles = company.company_roles.where(name: "Executive").to_a
      badge.grant_permission_to_roles(:send, roles)
    end
  end
end
