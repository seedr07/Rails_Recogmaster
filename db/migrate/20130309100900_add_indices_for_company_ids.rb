class AddIndicesForCompanyIds < ActiveRecord::Migration
  def up
    add_index :users, :company_id
    add_index :recognitions, :company_id
    add_index :attachments, [:owner_id, :owner_type]
  end

  def down
    remove_index :users, :company_id
    remove_index :recognitions, :company_id
    remove_index :attachments, column: [:owner_id, :owner_type]
  end
end
