class RefactorNominations < ActiveRecord::Migration
  def up
    remove_column :nominations, :badge_id
    remove_column :nominations, :is_archived
    add_column :nominations, :campaign_id, :integer
  end

  def down
    remove_column :nominations, :campaign_id
    add_column :nominations, :badge_id, :integer
    add_column :nominations, :is_archived, :boolean, default: false
    add_index :nominations, :badge_id


  end
end
