class PointHistory < ActiveRecord::Base
  belongs_to :owner, polymorphic: true, autosave: true

  validates :owner_id, :owner_type, :start_date, :end_date, presence: true
  validates :start_date, uniqueness: {scope: [:owner_id, :owner_type]}
  validates :end_date, uniqueness: {scope: [:owner_id, :owner_type]}
  validate :must_have_points

  scope :users, ->{where(owner_type: "User")}
  # def self.save_weekly_history!
  #   start_date = 1.week.ago
  #   end_date = Time.now
  #   Company.all.each do |company|
  #     company.users.each do |user|
  #       record!(user, start_date, end_date)
  #     end

  #     company.teams.each do |team|
  #       record!(team, start_date, end_date)
  #     end
  #   end
  # end

  def self.generate_for_company(company, start_date, end_date)
    company.users.each do |user|
      record!(user, start_date, end_date)
    end
  end

  # def self.generate_for(object)
  #   start_date = object.created_at.beginning_of_week
  #   end_date = Time.now
  #   while(start_date < end_date)
  #     record!(object, start_date, start_date.in(1.week))
  #     start_date += 1.week
  #   end
  # end

  def self.record!(object, start_date=1.week.ago, end_date=Time.now)
    # puts "Recording points history for #{object.class}:#{object.id} - #{start_date}..#{end_date}"
    point_history = where(start_date: start_date.to_date, end_date: end_date.to_date, owner: object).first_or_initialize
    report = "Report::#{object.class}".constantize.new(object, start_date, end_date)
    point_history.points = report.points if report.respond_to?(:points)
    point_history.team_points = report.team_points if report.respond_to?(:team_points)
    point_history.member_points = report.member_points if report.respond_to?(:member_points)
    point_history.save!
  rescue => e
    puts ""
  end

  private
  def must_have_points
    if self.points.blank? && self.team_points.blank? && self.member_points.blank?
      errors.add(:points, "must be set")
    end
  end
end
