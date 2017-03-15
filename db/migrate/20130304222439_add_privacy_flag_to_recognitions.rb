class AddPrivacyFlagToRecognitions < ActiveRecord::Migration
  def change
    add_column :recognitions, :is_public, :boolean, default: false
  end
end
