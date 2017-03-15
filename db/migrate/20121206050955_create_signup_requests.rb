class CreateSignupRequests < ActiveRecord::Migration
  def change
    create_table :signup_requests do |t|
      t.string :email
      t.string :pricing

      t.timestamps
    end
  end
end
