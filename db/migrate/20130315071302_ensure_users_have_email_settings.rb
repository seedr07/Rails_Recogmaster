class EnsureUsersHaveEmailSettings < ActiveRecord::Migration
  def up
    retries = 0
    begin
    User.reset_column_information
    EmailSetting.reset_column_information
    User.all.each do |u|
      u.build_email_setting.save(validate: false)
    end
    rescue Exception => e
      if retries + 1 < 10
        retries += 1
        ActiveRecord::Base.establish_connection
        retry
      else
        puts "retry: #{retries}"
      end
    end
  end

  def down
  end
end
