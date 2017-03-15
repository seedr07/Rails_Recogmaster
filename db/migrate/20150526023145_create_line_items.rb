class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      t.integer :company_id
      t.integer :subscription_id
      t.integer :invoice_id
      t.decimal :amount, precision: 10, scale: 2
      t.string :description
      t.string :currency, default: "USD"
      t.text :stripe_attributes
      t.timestamps
    end
  end
end
