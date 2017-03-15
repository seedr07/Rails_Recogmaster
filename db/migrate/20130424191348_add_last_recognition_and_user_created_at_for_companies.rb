class AddLastRecognitionAndUserCreatedAtForCompanies < ActiveRecord::Migration
  def up
    add_column :companies, :last_recognition_created_at, :datetime
    add_column :companies, :last_user_created_at, :datetime
    Company.reset_column_information
    Company.with_deleted.all.each do |c|
      #c.update_attribute(:last_recognition_created_at, Recognition.where(company_id: c.id).maximum(:created_at)) if c.recognition_count > 1
      #c.update_attribute(:last_user_created_at, User.where(company_id: c.id).maximum(:created_at)) if c.user_count > 1
    end
  end
  
  def down
    remove_column :companies, :last_recognition_created_at
    remove_column :companies, :last_user_created_at
  end
end
