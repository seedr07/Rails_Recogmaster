class CreateRewards < ActiveRecord::Migration
  def change
    create_table :rewards do |t|
      t.integer :user_id
      t.integer :order_id
      t.integer :recognition_id
      t.string :tango_customer
      t.string :tango_account
      t.text :reward_data
      t.timestamps
    end
  end
end
