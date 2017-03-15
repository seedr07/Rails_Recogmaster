class ChangeEnabledToArchivedOnSubscriptions < ActiveRecord::Migration
  def change
    rename_column :subscriptions, :enabled, :archived
    Subscription.where(archived: true).update_all("archived = !archived")
  end
end
