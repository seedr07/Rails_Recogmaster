class AnniversariesController < ApplicationController

def change_roles
	roles = params[:roles] || {}
	teams = params[:teams] || {}
	users = params[:users] || {}
	assign_roles(roles)
	assign_teams(teams)
	render nothing: true
 end 

 def assign_roles(roles)
 	temp_hash = @company.anniversary_notifieds
 	temp_hash[:role_ids] = roles.map{|role_id, on_off| role_id.to_i}
 	@company.anniversary_notifieds = temp_hash
  	@company.save
 end

 def assign_teams(teams)
 	temp_hash = @company.anniversary_notifieds
 	temp_hash[:team_ids] = teams.map{|team_id, on_off| team_id.to_i}
 	@company.anniversary_notifieds = temp_hash
  	@company.save
 end

 def assign_users(users)
 end


 



end
