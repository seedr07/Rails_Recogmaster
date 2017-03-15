class AddRecognitionCounterCacheToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :received_recognitions_count, :integer
  end
end
