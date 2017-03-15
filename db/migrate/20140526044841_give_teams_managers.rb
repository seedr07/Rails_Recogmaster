class GiveTeamsManagers < ActiveRecord::Migration
  def change

    inserts = []
    Company.includes(teams: :team_managers, users: :user_roles).each do |c|
      c.teams.each do |t|
        if t.team_managers.empty?
          c.company_admins.each do |ca|
            inserts.push "(#{t.id}, #{ca.id})"
          end
        end
      end
    end
    unless inserts.empty?
      sql = "INSERT INTO team_managers (`team_id`, `manager_id`) VALUES #{inserts.join(", ")}"
      ActiveRecord::Base.connection.execute sql
    end
  end
end
