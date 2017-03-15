class CreateRewardsAgain < ActiveRecord::Migration
  def up
    drop_table :rewards if ActiveRecord::Base.connection.table_exists? 'rewards'
    drop_table :redemptions if ActiveRecord::Base.connection.table_exists? 'redemptions'
    create_table :rewards do |t|
    	t.string :title
    	t.integer :company_id
    	t.text :description
    	t.integer :points
    	t.timestamps
    end
  end

  def down
    drop_table :rewards
  end
end
