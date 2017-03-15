require File.join(Rails.root, 'spec/support/sample_data')
namespace :recognize do

  desc "Drop; Create;"
  task :wipe => :environment do
    prevent_production_env!
    prevent_production_server!

    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
  end

  desc 'Drop; Create; AND migrate'
  task :reset => :wipe do
    prevent_production_env!
    prevent_production_server!

    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
  end
  
  desc 'Load a database backup and migrate, usage: recognize:load_db file=db/mydbbackup.sql'
  task :load_db => :wipe do
    prevent_production_env!
    prevent_production_server!

    f = ENV['file']
    raise "You must pass in a file with file='mysqldb.sql' parameter" if f.blank?
    
    c = ActiveRecord::Base.connection_config
    ustr = c[:username].blank? ? "" : "-u#{c[:username]}"
    pstr = c[:password].blank? ? "" : "-p#{c[:password]}"
    host = c[:host].blank? ? "" : "-h#{c[:host]}"
    execstr = "mysql #{host} #{ustr} #{pstr} #{c[:database]} < #{f}"
    puts "running: #{execstr}"
    `#{execstr}`
    Rake::Task['recognize:sanitize_db'].invoke
    Rake::Task['db:migrate'].invoke
  end

  desc 'Sanitize database'
  task :sanitize_db  => :environment do
    Rake::Task['recognize:sanitize_emails'].invoke
    Rake::Task['recognize:sanitize_subscriptions'].invoke
    Rake::Task['recognize:sanitize_authentications'].invoke
  end

  desc 'Backup mysql db' 
  task :backup_db => :environment do
    filename = "recognize_#{Rails.env.to_s.downcase}_#{Time.now.strftime("%Y%m%d%H%I%S")}.sql.gz"
    filepath = "tmp/#{filename}"

    c = ActiveRecord::Base.connection_config
    ustr = c[:username].blank? ? "" : "-u#{c[:username]}"
    pstr = c[:password].blank? ? "" : "-p#{c[:password]}"
    host = c[:host].blank? ? "" : "-h#{c[:host]}"
    execstr = "mysqldump --default-character-set=utf8mb4 #{host} #{ustr} #{pstr} #{c[:database]} | gzip --best > #{filepath}"
    `#{execstr}`
    puts filepath
  end

  desc 'Upload a backup file to s3'
  task :upload_backup, :file, :needs do |t, args|
    raise "This task must be run in production environment to connect with AWS" unless Rails.env.production?
    raise "You must specify a path to a file to upload with: file=<pathtofile>" unless ENV['file'].present? or args[:file].present?

    f  = ENV['file'] || args[:file]
    b = BackupAttachment.new(file: File.open(f))
    b.save!
  end

  desc 'Make a backup of mysql db and upload it to s3'
  task :backup_and_upload => :environment do
    backupfile = capture_stdout {Rake::Task['recognize:backup_db'].invoke}
    Rake::Task['recognize:upload_backup'].invoke(backupfile.strip)
  end

  
  desc 'Sanitize the email addresses for a particular database by adding a new tld'
  task :sanitize_emails => :environment do
    prevent_production_env!
    prevent_production_server!

    ActiveRecord::Base.connection.execute("update users set email=concat(email, '.not.real.tld') where email NOT LIKE '%recognizeapp.com' AND email NOT LIKE '%planet.io'")
    ActiveRecord::Base.connection.execute("update companies set domain=concat(domain, '.not.real.tld') where domain NOT LIKE '%recognizeapp.com' AND domain NOT LIKE '%planet.io' AND domain <> 'users'")    
    ActiveRecord::Base.connection.execute("update users set network=concat(network, '.not.real.tld') where network NOT LIKE '%recognizeapp.com' AND network NOT LIKE '%planet.io' AND network <> 'users'")    rescue nil 
    ActiveRecord::Base.connection.execute("update teams set network=concat(network, '.not.real.tld') where network NOT LIKE '%recognizeapp.com' AND network NOT LIKE '%planet.io' AND network <> 'users'")    rescue nil 
    ActiveRecord::Base.connection.execute("update recognition_recipients set recipient_network=concat(network, '.not.real.tld') where network NOT LIKE '%recognizeapp.com' AND network NOT LIKE '%planet.io' AND network <> 'users'")    rescue nil 
    ActiveRecord::Base.connection.execute("update support_emails set email=concat(email, '.not.real.tld') where email NOT LIKE '%recognizeapp.com' AND email NOT LIKE '%planet.io'")
    ActiveRecord::Base.connection.execute("update users set phone='' where email NOT LIKE '%recognizeapp.com' AND email NOT LIKE '%planet.io'")

  end

  desc 'Sanitize subscription data because it may point to a different Stripe endpoint(live vs test)'
  task :sanitize_subscriptions => :environment do
    prevent_production_env!
    prevent_production_server!

    ActiveRecord::Base.connection.execute("truncate subscriptions") rescue nil
  end

  task :sanitize_authentications => :environment do
    prevent_production_env!
    prevent_production_server!

    user_ids = User.where.not(network: "recognizeapp.com").where.not(network: "planet.io").pluck(:id)
    Authentication.where(user_id: user_ids).delete_all
  end

  desc "Initialize Recognize. To be run from fresh install."
  task :init => :environment do
    prevent_production_env!
    prevent_production_server!

    Rake::Task['tmp:clear'].invoke
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    load "#{Rails.root.to_s}/db/schema.rb"
    # Rake::Task['db:migrate'].invoke
    Rails.application.load_seed

  end

  desc "Resets all roles assignments" 
  task :reset_roles => :environment do
    prevent_production_env!
    prevent_production_server!

    UserRole.delete_all
  end
  
  desc "Deletes all the badges and initializes with a new set"
  task :initialize_badges => :environment do
    prevent_production_env!
    prevent_production_server!

    ActiveRecord::Base.connection.execute("TRUNCATE badges") 
    Badge.reset_column_information
    Badge::SET.each{|b| FactoryGirl.create("#{b}_badge") }
  end

  desc 'Generate a sample company with users, recognitions and approvals'
  task :generate_sample_company => :environment do
    prevent_production_env!
    prevent_production_server!

    domain = ENV['domain']
    num_users = ENV['num_users'] || 9423
    num_recognitions = ENV['num_recognitions'] || 21
    
    if domain.blank?
      puts "Please specify a domain with the command 'rake recognize:generate_sample_company domain=yourdomain.com"

    else    
      
      if Company.find_by_domain(domain).present?
        puts "sorry that domain already exists, try a different one or run 'rake recognize:init' to start fresh"
      else
        puts "generating #{domain} with #{num_users} users and #{num_recognitions} recognitions"
        SampleData.generate(domain, num_users, num_recognitions)
      end

    end
  end
  
  desc 'add images to the initech data set'
  task :add_images_to_initech => :environment do
    prevent_production_env!
    prevent_production_server!

    data = [[8, "rlivingston@initech.com", "http://ia.media-imdb.com/images/M/MV5BMTg2NjY4MjcwN15BMl5BanBnXkFtZTcwMjM4MzI0Mg@@._V1._SY314_CR138,0,214,314_.jpg"],
    [9, "jenn.anistown@initech.com", "http://ia.media-imdb.com/images/M/MV5BNjk1MjIxNjUxNF5BMl5BanBnXkFtZTcwODk2NzM4Mg@@._V1._SY314_CR2,0,214,314_.jpg"],
    [10, "david.herman@initech.com", "http://ia.media-imdb.com/images/M/MV5BMTQ0NDQ2ODY5OV5BMl5BanBnXkFtZTYwMTQxOTgy._V1._SY314_CR8,0,214,314_.jpg"],
    [11, "ajay.naidu@initech.com", "http://ia.media-imdb.com/images/M/MV5BMTY5NjU0NTU5OV5BMl5BanBnXkFtZTYwMTU4MzA2._V1._SY314_CR4,0,214,314_.jpg"],
    [12, "diedrich.bader@initech.com", "http://ia.media-imdb.com/images/M/MV5BMTkzMTkyNzYyOV5BMl5BanBnXkFtZTYwNTMyNDE0._V1._SY314_CR7,0,214,314_.jpg"],
    [13, "alexandra.wentworth@initech.com", "http://ia.media-imdb.com/images/M/MV5BMTgzMzU1MzI5N15BMl5BanBnXkFtZTcwMzE2Mzc1MQ@@._V1._SY314_CR10,0,214,314_.jpg"],
    [14, "kinna.mcinroe@initech.com", "http://ia.media-imdb.com/images/M/MV5BMjE4Nzg3NzUzMV5BMl5BanBnXkFtZTcwMDY1MzI3NA@@._V1._SX214_CR0,0,214,314_.jpg"],
    [15, "greg.pitts@initech.com", "http://ia.media-imdb.com/images/M/MV5BMTg3NDU1NDY0Ml5BMl5BanBnXkFtZTcwNzA3NjgyNA@@._V1._SY314_CR18,0,214,314_.jpg"],
    [16, "peter.gibbons@initech.com",  "http://ia.media-imdb.com/images/M/MV5BMTg2NjY4MjcwN15BMl5BanBnXkFtZTcwMjM4MzI0Mg@@._V1._SY314_CR138,0,214,314_.jpg"],
    [17, "samir.nagheenanajar@initech.com", "http://ia.media-imdb.com/images/M/MV5BMTM5NjQ2OTIwMV5BMl5BanBnXkFtZTcwMjcxOTYyMQ@@._V1._SY314_CR5,0,214,314_.jpg"],
    [18, "bill.lumbergh@initech.com", "http://ia.media-imdb.com/images/M/MV5BMTQwODU5MTU3OF5BMl5BanBnXkFtZTcwMzk2NzMzMw@@._V1._SY314_CR9,0,214,314_.jpg"],
    [19, "milton.waddams@initech.com", "http://ia.media-imdb.com/images/M/MV5BMTg1MDc4MjExNF5BMl5BanBnXkFtZTcwMzQ4OTY0Mw@@._V1._SX214_CR0,0,214,314_.jpg"]]

    data.each{|u| 
      user = User.find_by_email(u[1])
      user.avatar.remote_file_url = u[2]
      user.avatar.save!
    }    
    
    #hack delete ron livingston for sxsw
    User.find_by_email("rlivingston@initech.com").destroy
  end
  
  desc 'Prep initech sample database'
  task :prep_initech => :environment do
    prevent_production_env!
    prevent_production_server!

    SampleData::File.generate!("db/sample_recognition_data.csv", "db/initech_users.csv")
  end
  desc 'Prep initech sample database'
  task :prep_theoffice => :environment do
    prevent_production_env!
    prevent_production_server!

    SampleData::File.generate!("db/sample_recognition_data.csv", "db/theoffice_users.csv")
  end

  desc 'Prep Planet sample database'
  task :prep_planet => :environment do
    prevent_production_env!
    prevent_production_server!

    SampleData::File.generate!("db/sample_recognition_data.csv", "db/planet_users.csv")
  end  

  desc 'Generate daily sample data for planet and recognize'
  task :generate_daily_sample_data => :environment do
    prevent_production_server!
    SampleData::File.generate!('db/sample_recognition_data.csv', 'db/planet_users.csv', network: 'planet.io') rescue nil
    SampleData::File.generate!('db/sample_recognition_data.csv', 'db/initech_users.csv', network: 'planet.io') rescue nil
    SampleData::File.generate!('db/sample_recognition_data.csv', 'db/planet_users.csv', network: 'recognizeapp.com') rescue nil
    SampleData::File.generate!('db/sample_recognition_data.csv', 'db/initech_users.csv', network: 'recognizeapp.com') rescue nil
  end

  desc 'Get users emails as a line delimited file'
  task :user_list => :environment do
    filename = ENV['filename']
    puts filename
    if filename.blank?
      puts "Usage: rake recognize:user_list filename=<yourfilename>"
      exit
    end
    list = User.marketable_users.collect{|s| s.email}.join("\n")
    File.open(filename, 'w'){|f| f.write(list)}
  end

  desc 'Get Yammer users emails as a line delimited file'
  task :yammer_user_list => :environment do
    filename = ENV['filename']
    puts "Writing #{filename}"
    if filename.blank?
      puts "Usage: rake recognize:user_list filename=<yourfilename>"
      exit
    end

    list = User
      .marketable_yammer_users
      .map{|u| [unsanitize(u.email), u.first_name, u.last_name, unsanitize(u.company.domain)].join(",")}
      .join("\n")

    File.open(filename, 'w'){|f| f.write(list)}
  end

  desc 'prime all the caches, also wipes out all tmp'
  task :prime_caches => :environment do
    Company.prime_caches!
  end

  desc 'run tests'
  task :test  do
    result = system("bundle exec rspec spec")
    if !result
      puts "Hmm...looks like we had a catastrophic failure.  Fear not, lets re-initialize your test db and see what happens"
      result = system("bundle exec rake recognize:init RAILS_ENV=test; bundle exec rspec spec")
    end
    puts "The output of test completed with status: #{result.inspect}"
  end
  
  desc 'Sync coupons with Stripe'
  task :sync_coupons  => :environment do
    Coupon.sync_with_stripe!
  end
  
  desc 'Unsubscribe a list of emails'
  task :unsubscribe => :environment do
    filename = ENV['filename']
    puts filename
    if filename.blank?
      puts "Usage: rake recognize:unsubscribe filename=<yourfilename>"
      exit
    end
    f = File.open(filename)

    emails = f.readlines.map { |email|  email.chomp}
    users = User.includes(:email_setting).where(email: emails)
    EmailSetting.where(user_id: users.map(&:id)).update_all(["email_settings.global_unsubscribe = ?", true])
  end

  desc 'Ensure badges' 
  task :ensure_badges => :environment do
    domains = ["recognizeapp.com", "planet.io"]
    badges = Dir["./app/assets/images/badges/200/*"]
    companies = Company.all#Company.where(domain: domains)
    companies.each do |c|
      c.company_badges.each do |badge|
        badge.remove_image!
        badge.save!(validate: false)
        badge.image = File.open(badges[rand(badges.length)])
        badge.save!(validate: false)
      end
    end
  end
end

require "stringio"

def capture_stderr
  previous, $stderr = $stderr, StringIO.new
  yield
  $stderr.string
ensure
  $stderr = previous
end

def capture_stdout
  previous, $stdout = $stdout, StringIO.new
  yield
  $stdout.string
ensure
  $stdout = previous
end

def prevent_production_env!
    raise "You may not run this in production environment!".red if Rails.env.production?
end

def prevent_production_server!
    raise "You many not run this against recognizeapp.com".red if Recognize::Application.config.host == "recognizeapp.com"  
end

def unsanitize(str)
  str.gsub(".not.real.tld", "")
end
