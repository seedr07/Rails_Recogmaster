class UpdateUsersWithoutVerifiedAt < ActiveRecord::Migration
  def up
    add_index :authentications, :user_id
    add_index :authentications, :provider
    User.includes(:authentications).where(verified_at: nil).select(&:verified?).each do |u|
      #u.update_attribute(:verified_at, u.authentications[0].created_at)
      User.where(id: u.id).update_all("verified_at = '#{u.authentications[0].created_at.to_formatted_s(:db)}'")
    end
  end

  def down
    remove_index :authentications, :user_id
    remove_index :authentications, :provider
  end
end
