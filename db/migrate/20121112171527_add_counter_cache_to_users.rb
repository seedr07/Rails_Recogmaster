class AddCounterCacheToUsers < ActiveRecord::Migration
  def up
    add_column :users, :received_recognitions_count, :integer, :default => 0
    add_column :users, :sent_recognitions_count, :integer, :default => 0
    add_column :users, :given_recognition_approvals_count, :integer, :default => 0
    User.reset_column_information
    User.with_deleted.all.each do |u|
      u.update_attribute :received_recognitions_count, u.received_recognitions.length
      u.update_attribute :sent_recognitions_count, u.sent_recognitions.length
      u.update_attribute :given_recognition_approvals_count, u.given_recognition_approvals.length
    end
  end
  
  def down
    remove_column :users, :received_recognitions_count
    remove_column :users, :sent_recognitions_count
    remove_column :users, :given_recognition_approvals_count
  end
end
