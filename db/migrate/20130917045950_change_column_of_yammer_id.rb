class ChangeColumnOfYammerId < ActiveRecord::Migration
  def up
    change_column :users, :yammer_id, :string
  end

  def down
    change_column :users, :yammer_id, :integer
  end
end
