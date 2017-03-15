class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name
      t.string :short_name
      t.string :long_name
      t.timestamps
    end
  end
end
