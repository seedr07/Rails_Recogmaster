class ChangeDateFormatInSubscriptions < ActiveRecord::Migration
	def up
	   	change_column :subscriptions, :invoice_date, :date
	end

	def down
		change_column :subscriptions, :invoice_date, :datetime
	end
end
