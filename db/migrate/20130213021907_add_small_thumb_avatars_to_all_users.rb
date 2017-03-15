class AddSmallThumbAvatarsToAllUsers < ActiveRecord::Migration
  def up
    set = AvatarAttachment.all.select{|a| a.file.small_thumb.blank?}
    set.each{|s| s.recreate_versions! rescue nil}
  end
end
