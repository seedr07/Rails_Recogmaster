class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :name
      t.string :label
      t.text :description
      t.decimal :price_per_user

      t.timestamps
    end
  end
end
