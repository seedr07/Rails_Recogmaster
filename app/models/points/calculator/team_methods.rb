module Points
  module Calculator
    module TeamMethods
      def calculate_interval_points
        report = Report::Team.new(self, interval_start_date, Time.now)
        return Hashie::Mash.new(team_points: report.team_points, member_points: report.member_points)
      end

      def calculate_total_points
        report = Report::Team.new(self, 50.years.ago, Time.now)
        return Hashie::Mash.new(team_points: report.team_points, member_points: report.member_points)
      end

      def update_all_points!
        update_total_points!
        update_interval_points!
      end

      def update_total_points!
        totals = calculate_total_points
        update_column(:total_team_points, totals.team_points)
        update_column(:total_member_points, totals.member_points)
      end

      def update_interval_points!
        totals = calculate_interval_points
        update_column(:interval_team_points, totals.team_points)
        update_column(:interval_member_points, totals.member_points)
      end

      def total_points
        total_team_points + total_member_points
      end  

      def total_interval_points
        interval_team_points + interval_member_points
      end
   
      def interval_member_recognitions
        member_recognitions.where("created_at > ?", interval_start_date)
      end

      def interval_team_recognitions
        team_recognitions.where("created_at > ?", interval_start_date)
      end

    end


  end
end