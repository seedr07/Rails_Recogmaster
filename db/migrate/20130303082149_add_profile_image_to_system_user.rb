class AddProfileImageToSystemUser < ActiveRecord::Migration
  def change
    user = User.with_deleted.find_by_email("app@recognizeapp.com")
    if user
      f = File.open(Rails.root.join("app/assets/images/chrome/logo_180x180.png"))
      user.avatar.file = f
      user.avatar.save!
    end
  end
end
