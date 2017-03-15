class UpdateUsersAndTeamsIntervalPoints < ActiveRecord::Migration
  def change    
    return unless Rails.env.production?
    Company.all.each_with_index do |c, i|
      puts "resetting points for company(#{i}/#{Company.count})"
      Points::Resetter.new(c).reset!
      c.users.map(&:update_all_points!)
      c.teams.map(&:update_all_points!)
    end
  end
end
