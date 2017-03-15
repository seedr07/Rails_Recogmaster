class ReallyReallyPointsUpdateForCompanies < ActiveRecord::Migration
  def change
    Company.all.each do |c|
      begin
        puts "Initializing point values for: #{c.domain}"
        c.send(:initialize_point_values)
        c.save!
      rescue => e
        puts "Caught exception: #{e.message}"
      end
    end
  end
end
