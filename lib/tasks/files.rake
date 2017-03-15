require 'csv'

namespace :files do
	which = false
  desc "Randomize list split in two"
  task :randomize_split => :environment do
  	file = ENV['file']
  	CSV.open("tmp/random_list1.csv",'w') do |list1|
		  CSV.open("tmp/random_list2.csv",'w') do |list2|
		    CSV.foreach(file) do |row|
		      (which == false ? list1 : list2) << row

		      which = which == false ? true : false
		    end
		  end
		end
  end
end