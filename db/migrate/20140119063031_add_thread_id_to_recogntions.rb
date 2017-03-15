class AddThreadIdToRecogntions < ActiveRecord::Migration
  def change
    add_column :recognitions, :yammer_thread_id, :string
  end
end
