class AddPostToYammerGroupId < ActiveRecord::Migration
  def change
    add_column :companies, :post_to_yammer_group_id, :string
  end
end
