class AddNominationMessageIsRequiredToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :nomination_message_is_required, :boolean, default: false
  end
end
