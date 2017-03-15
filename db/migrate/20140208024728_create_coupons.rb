class CreateCoupons < ActiveRecord::Migration
  def change
    create_table :coupons do |t|
      t.string :code
      t.text :message
      t.text :stripe_data
      t.datetime :deleted_at
    end
  end
end
