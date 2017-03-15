class AddRequestedUserCountToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :requested_user_count, :integer
  end
end
