class UpdateNominationsToReflectVoteModel < ActiveRecord::Migration
  def up
    remove_column :nominations, :sender_id
    remove_column :nominations, :message
    remove_column :nominations, :sender_company_id
    add_column :nominations, :recipient_company_id, :integer
    add_index :nominations, :recipient_company_id
    add_column :nominations, :votes_count, :integer
  end

  def down
    remove_index :nominations, :recipient_company_id
    remove_column :nominations, :recipient_company_id
    add_column :nominations, :sender_id, :integer
    add_column :nominations, :message, :text
    add_column :nominations, :sender_company_id, :integer
    remove_column :nominations, :votes_count
  end
end
