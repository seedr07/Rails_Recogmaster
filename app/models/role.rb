class Role 
  include IdNameMethods


  DATA = [
    [SYSTEM_USER=0, :system_user, "System User"],
    [ADMIN=1, :admin, "Admin"],
    [COMPANY_ADMIN=2, :company_admin, "Company Admin"],
    [TEAM_LEADER=3, :team_leader, "Team Leader"],
    [EMPLOYEE=4, :employee, "Employee"],
    [EXECUTIVE=5,:executive, "Executive"],
    [DIRECTOR=6, :director, "Director"]

  ]

  # Class accessors
  # Eg. Role.admin, Role.company_admin
  class << self
    DATA.each do |role_data|
      role_value, role_sym, short_name = *role_data
      define_method("#{role_sym}") { find(role_value)} 
    end
  end

  module UserMethods
    # User interrogators
    # Eg. user.employee?, user.admin?
    DATA.each do |role_data|
      role_value, role_sym, short_name = *role_data
      define_method("#{role_sym}?") { has_role?(role_value) }
    end

    def roles
      Role::Collection.new(self, user_roles.map{|ur| Role.find(ur.role_id)})
    end

    def roles=(new_roles)
      new_roles.each{|role| roles << role}
    end

    private
    def has_role?(role_id)
      user_roles.any?{|ur| ur.role_id == role_id}
    end
  end  

  class Collection < Array
    attr_reader :user

    def initialize(user, roles)
      @user = user
      super(roles)
    end

    def <<(new_role)
      user.user_roles.create(role_id: new_role.id)
      super
    end

  end
end
