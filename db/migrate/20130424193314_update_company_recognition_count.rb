class UpdateCompanyRecognitionCount < ActiveRecord::Migration
  def up
    add_column :companies, :user_recognition_count, :integer, default: 0
    Company.reset_column_information
    Company.with_deleted.all.each do |c|
      #c.update_attribute(:user_recognition_count, Recognition.where(["company_id = ? AND badge_id NOT IN (?)", c.id, Badge.system_badges.pluck(:id)]).count)
    end
  end

  def down
    remove_column :companies, :user_recognition_count
  end
end
