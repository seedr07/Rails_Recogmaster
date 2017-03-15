class UpdateBadgesTable < ActiveRecord::Migration
  def change
    add_column :badges, :company_id, :integer
    add_column :badges, :image, :string
    add_index :badges, :company_id
  end
end
