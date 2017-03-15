class UpdateTeamTotalPoints < ActiveRecord::Migration
  def up
    # ensure teams have created by attribute
    ensure_teams_have_created_by!

    lastteamid = Team.last.try(:id)
    lastcompanyid = Company.last.try(:id)
    failed = []
    Team.all.each do |team|
      puts "Updating team: #{team.id}/#{lastteamid} - company(#{team.company_id}/#{lastcompanyid})"
      begin
        team.update_all_points!
      rescue StandardError => e
        msg =  "Failed updating team: #{team.name}(#{team.id}) - #{team.company.try(:domain)}(#{team.company_id})"
        failed << msg
        puts msg
      end
    end
    puts "Teams that failed: "
    puts failed.join("\n")
  end

  private
  def ensure_teams_have_created_by!
    lastteamid = Team.last.try(:id)
    lastcompanyid = Company.last.try(:id)

    Company.unscoped do
      User.unscoped do
        teams = Team.includes(:company).where(created_by_id: nil)
        teams.each do |team|
          begin
            puts "Ensuring team created by: #{team.id}/#{lastteamid} - company(#{team.company_id}/#{lastcompanyid})"
            team.created_by_id = team.company.company_admin.id
            team.save
          rescue => e
          end
        end
      end
    end
  end
end
