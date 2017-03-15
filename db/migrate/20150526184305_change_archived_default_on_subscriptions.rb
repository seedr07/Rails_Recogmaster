class ChangeArchivedDefaultOnSubscriptions < ActiveRecord::Migration
  def change
    change_column :subscriptions, :archived, :boolean, default: false
  end
end
