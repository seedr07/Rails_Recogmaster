class AddSlugsToUsers < ActiveRecord::Migration
  def up
    add_column :users, :slug, :string
    User.reset_column_information
    User.with_deleted.all.each do |u|
      u.update_attribute(:slug, u.email_to_slug)
    end
  end
  
  def down
    remove_column :users, :slug
  end
end
