class UpdateRecognizeAccountToAllowAdminDashboard < ActiveRecord::Migration
  def up
    Company.where(domain: "recognizeapp.com").update_all("allow_admin_dashboard = true")
  end

  def down
  end
end
