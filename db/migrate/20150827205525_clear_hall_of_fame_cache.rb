class ClearHallOfFameCache < ActiveRecord::Migration
  def up
    Rails.cache.delete_matched(/HallOfFame/)    
  end
end
