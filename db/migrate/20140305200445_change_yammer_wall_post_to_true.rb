class ChangeYammerWallPostToTrue < ActiveRecord::Migration
  def up
    change_column :companies, :allow_posting_to_yammer_wall, :boolean, default: true
  end

  def down
  end
end
