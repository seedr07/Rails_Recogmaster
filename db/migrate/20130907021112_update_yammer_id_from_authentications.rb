class UpdateYammerIdFromAuthentications < ActiveRecord::Migration
  def up
    User.reset_column_information
#    Authentication.where(provider: "yammer").includes(:user).joins(:user).each do |auth|
#      auth.user.update_attribute(:yammer_id, auth.uid)
#    end
  end

  def down
  end
end
