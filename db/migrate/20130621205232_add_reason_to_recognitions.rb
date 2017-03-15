class AddReasonToRecognitions < ActiveRecord::Migration
  def change
    add_column :recognitions, :reason, :string
  end
end
