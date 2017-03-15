class LeaderboardSettings < ActiveRecord::Migration
  def change

    add_column :companies, :allow_you_stats, :boolean, default: true
    add_column :companies, :allow_top_employee_stats, :boolean, default: false

  end
end