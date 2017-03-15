class CreateSubscriptions < ActiveRecord::Migration
    def change
      create_table :subscriptions do |t|
        t.string :name
        t.decimal :price
        t.integer :user_count
        t.string :email
        t.integer :user_id
        t.string :stripe_customer_token

        t.timestamps
      end
    end
end
