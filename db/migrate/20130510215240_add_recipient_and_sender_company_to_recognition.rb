class AddRecipientAndSenderCompanyToRecognition < ActiveRecord::Migration

  def up
    # company association columns
    rename_column :recognitions, :company_id, :sender_company_id
    add_column :recognitions, :recipient_company_id, :integer

    # company full counter cache
    rename_column :companies, :recognitions_count, :sent_recognitions_count
    add_column :companies, :received_recognitions_count, :integer

    # company user based recognition counter cache
    rename_column :companies, :user_recognition_count, :sent_user_recognitions_count
    add_column :companies, :received_user_recognitions_count, :integer

    # company last sent/received at columns
    rename_column :companies, :last_recognition_created_at, :last_recognition_sent_at
    add_column  :companies, :last_recognition_received_at, :datetime

    Recognition.reset_column_information

    add_index :recognitions, :recipient_company_id
    add_index :recognitions, [:sender_company_id, :recipient_company_id]

    str = "Updating user data, please wait...".split(//)
    ActiveRecord::Base.establish_connection
    Recognition.with_deleted.all.each do |r|
      print (str.shift || ".")
      #r.update_attribute :recipient_company_id, r.sender_company_id
    end    
    print("\n")
  end

  def down
    remove_index :recognitions, :recipient_company_id
    remove_index :recognitions, [:sender_company_id, :recipient_company_id]

    rename_column :recognitions, :sender_company_id, :company_id
    remove_column :recognitions, :recipient_company_id

    rename_column :companies, :sent_recognitions_count, :recognitions_count
    remove_column :companies, :received_recognitions_count

    rename_column :companies, :sent_user_recognitions_count, :user_recognition_count
    remove_column :companies, :received_user_recognitions_count

    rename_column :companies, :last_recognition_sent_at, :last_recognition_created_at
    remove_column :companies, :last_recognition_received_at

  end
end
