# t.integer  "login_count",         :default => 0,  :null => false
# t.integer  "failed_login_count",  :default => 0,  :null => false
# t.datetime "last_request_at"
# t.datetime "current_login_at"
# t.datetime "last_login_at"
# t.string   "current_login_ip"
# t.string   "last_login_ip"

class AddInLastLoginFieldsForUser < ActiveRecord::Migration
  def up
    add_column :users, :login_count, :integer, default: 0, null: false
    add_column :users, :failed_login_count, :integer, default: 0, null: false
    add_column :users, :last_request_at, :datetime
    add_column :users, :current_login_at, :datetime
    add_column :users, :last_login_at, :datetime
    add_column :users, :current_login_ip, :string
    add_column :users, :last_login_ip, :string
  end

  def down
    [:login_count, :failed_login_count, :last_request_at, :current_login_at, :last_login_at, :current_login_ip, :last_login_ip].each do |f|
      remove_column :users, f
    end
  end
end
