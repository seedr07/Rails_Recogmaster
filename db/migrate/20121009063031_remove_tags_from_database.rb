class RemoveTagsFromDatabase < ActiveRecord::Migration
  def up
    drop_table :tags
    drop_table :badges_tags
  end

  def down
    create_table :badges_tags, :id => false do |t|
      t.integer :badge_id
      t.integer :tag_id
    end
    create_table :tags do |t|
      t.string :name
      t.string :short_name
      t.string :long_name
      t.timestamps
    end        
  end
end
