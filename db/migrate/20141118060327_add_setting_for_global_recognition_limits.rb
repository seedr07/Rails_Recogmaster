class AddSettingForGlobalRecognitionLimits < ActiveRecord::Migration
  def change
    add_column :companies, :recognition_limit_frequency, :integer
    add_column :companies, :recognition_limit_interval_id, :integer
  end
end
