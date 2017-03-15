class AddDeletedAtIndexToUsersAndRecognitions < ActiveRecord::Migration
  def change
    add_index :users, :deleted_at
    add_index :recognitions, :deleted_at
  end
end
