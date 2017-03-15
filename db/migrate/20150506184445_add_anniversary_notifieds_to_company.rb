class AddAnniversaryNotifiedsToCompany < ActiveRecord::Migration
  def change
  	add_column :companies, :anniversary_notifieds, :text
  end
end
