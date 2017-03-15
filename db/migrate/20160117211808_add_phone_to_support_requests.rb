class AddPhoneToSupportRequests < ActiveRecord::Migration
  def change
    add_column :support_emails, :phone, :string
  end
end
