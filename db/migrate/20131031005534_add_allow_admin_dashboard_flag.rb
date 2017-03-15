class AddAllowAdminDashboardFlag < ActiveRecord::Migration
  def change
    add_column :companies, :allow_admin_dashboard, :boolean, default: false
  end
end
