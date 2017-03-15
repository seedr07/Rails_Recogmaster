class AddSlugToRecognitions < ActiveRecord::Migration
  def change
    add_column :recognitions, :slug, :string
  end
end
