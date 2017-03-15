class AddFeedbackTypeParamToContactForm < ActiveRecord::Migration
  def change
    add_column :support_emails, :type, :string
  end
end
