class CreateRedemptionsAgain < ActiveRecord::Migration
  def change
    create_table :redemptions do |t|
    	t.integer :user_id
    	t.integer :reward_id
    	t.integer :company_id
    	t.timestamps
    end

    add_index :redemptions, :user_id
    add_index :redemptions, :company_id
  end
end
