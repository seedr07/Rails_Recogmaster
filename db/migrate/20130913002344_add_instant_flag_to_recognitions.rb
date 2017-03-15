class AddInstantFlagToRecognitions < ActiveRecord::Migration
  def change
    add_column :recognitions, :is_instant, :boolean, default: false
  end
end
