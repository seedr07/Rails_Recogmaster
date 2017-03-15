class AllowYammerConnect < ActiveRecord::Migration
  def up
    add_column :companies, :allow_yammer_connect, :boolean, default: true
  end

  def down
  end
end
