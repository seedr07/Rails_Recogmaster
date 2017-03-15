class AddMessageClassToCoupons < ActiveRecord::Migration
  def change
    add_column :coupons, :css_class, :string
  end
end
