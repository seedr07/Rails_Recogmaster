class AddCounterCacheToRecognitions < ActiveRecord::Migration
  def up
    add_column :recognitions, :approvals_count, :integer, :default => 0
    Recognition.reset_column_information
    Recognition.with_deleted.all.each do |r|
      r.update_attribute :approvals_count, r.approvals.length
    end
  end
  
  def down
    remove_column :recognitions, :approvals_count
  end
end
