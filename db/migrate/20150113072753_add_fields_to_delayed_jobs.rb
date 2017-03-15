class AddFieldsToDelayedJobs < ActiveRecord::Migration
  def change
    add_column :delayed_jobs, :signature, :string
    add_column :delayed_jobs, :args, :text, limit: 4294967295
  end
end
