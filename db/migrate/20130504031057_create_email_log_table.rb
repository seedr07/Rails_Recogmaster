class CreateEmailLogTable < ActiveRecord::Migration
  def change
    create_table :email_logs do |t|
      t.string :from
      t.string :to
      t.string :subject
      t.text :body
      t.datetime :date
    end
  end

end
