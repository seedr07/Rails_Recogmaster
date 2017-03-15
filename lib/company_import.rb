# export spreadsheet to csv into ~/Downloads
# scp ~/Downloads/goodway.csv web@54.244.90.62:./sites/recognizeapp.com/current/tmp/
# Run this with: [RAILS_ENV=production] bin/rails r lib/company_import.rb 

# bin/rails r lib/company_import.rb --file=tmp/investorsgroup-hr.csv --schema=4 --domain=investorsgroup.com-Human-Resources --sender-email=trevor.hubert@investorsgroup.com --invite=false
# bin/rails r lib/company_import.rb --file=tmp/investorsgroup-marketing.csv --schema=5 --domain=investorsgroup.com-marketing --sender-email=trevor.hubert@investorsgroup.com --invite=false --date-format=%m/%d/%Y
# bin/rails r lib/company_import.rb --file=tmp/amtwoundcare.csv --schema=6 --domain=amtwoundcare.com --sender-email=tessa.hammond@amtwoundcare.com --date-format=%m/%d/%Y
# bin/rails r lib/company_import.rb --file=tmp/premiers.csv --schema=7 --domain=premiers.qld.gov.au --sender-email=renee.shea@premiers.qld.gov.au
# bin/rails r lib/company_import.rb --file=tmp/oqpc.csv --schema=8 --domain=premiers.qld.gov.au --sender-email=renee.shea@premiers.qld.gov.au
# bin/rails r lib/company_import.rb --file=tmp/igt-pilot.csv --schema=3 --domain=igt.com --sender-email=tonia.fulton@igt.com --invite=false
# bin/rails r lib/company_import.rb --file=tmp/brandtone.csv --schema=1 --domain=brandtone.com --sender-email=jay.ross@brandtone.com
# bin/rails r lib/company_import.rb --file=tmp/swdeligroup.csv --schema=9 --domain=swdeligroup.com --sender-email=kgrozdanich@swdeligroup.com
# bin/rails r lib/company_import.rb --file=tmp/shiningstartherapy.csv --schema=10 --domain=shiningstartherapy.com --sender-email=babraggs@shiningstartherapy.com --date-format=%m/%d/%Y --invite=false --extra-data=tmp/data.yml
# bin/rails r lib/company_import.rb --file=tmp/jetprivilege.csv --schema=10 --domain=jetprivilege.com --sender-email=manish.dureja@jetprivilege.com --date-format=%m/%d/%Y --invite=false

# To send out invites for a company that was imported with --invite=false
# c = Company.where(domain: "investorsgroup.com-Marketing.not.real.tld").first
# sender = User.where(first_name: "Trevor", last_name: "Hubert").first
# c.resend_invitations!(sender)

require 'optparse'
opts = {}

parser = OptionParser.new do |options|
  options.on '-f', '--file FILE', 'CSV file with data to import' do |arg|
    opts[:file] = arg
  end
  options.on '-d', '--domain DOMAIN', 'domain of the company to import into' do |arg|
    opts[:domain] = arg
  end
  options.on '-e', '--sender-email SENDER_EMAIL', 'sender email that be used to invite and make teams' do |arg|
    opts[:sender_email] = arg
  end
  options.on '-t', '--date-format DATE_FORMAT', 'format of dates in the import file' do |arg|
    opts[:date_format] = arg
  end
  options.on '-s', '--schema SCHEMA', 'schema format of input csv file' do |arg|
    opts[:schema] = arg
  end
  options.on '-i', '--invite INVITE', 'add and send invite. Default: true; If false, just adds user and marks user has not been invited so we can send invites at later date' do |arg|
    opts[:invite] = arg
  end

  options.on '-x', '--extra-data FILE', 'File to pull confidential data from.' do |arg|
    opts[:extra_data] = arg
  end
end

parser.parse! ARGV

file = opts[:file] || "tmp/goodway.csv"
domain = opts[:domain] || "goodwaygroup.com"
sender_email = opts[:sender_email] || "jpettijohn@goodwaygroup.com"
# twodigityear = true
date_format = opts[:date_format] || "%m/%d/%y"
schema = (opts.has_key?(:schema) ? opts[:schema].to_i : 3) - 1
send_invitation = opts.has_key?(:invite) && opts[:invite] == "false"  ? false : true

extra_data = opts.has_key?(:extra_data) ? YAML.load_file(opts[:extra_data]) : {}
default_password = extra_data["default_password"]

# [0 , 1,     2,     3,    4,            5,         6,    7,          8,                9           ]
# [EmailAddress,FirstName, LastName]
SCHEMA1 = {
  email: 0,
  first_name: 1,
  last_name: 2,
  job_title: 3,
  team_name: 4,
  start_date: 5
}

SCHEMA2 = {
  team_name: 0,
  first_name: 1,
  last_name: 2,
  start_date: 3,
  job_title: 7
}

SCHEMA3 = {
  first_name: 0,
  last_name: 1,
  email: 2,
  start_date: 3,
  team_name: 4,
  job_title: 5
}

# investorsgroup - HR
SCHEMA4 = {
  email: 0,
  first_name: 1,
  last_name: 2,
  job_title: 3,
  start_date: 6
}

# investorsgroup - Marketing
SCHEMA5 = {
  email: 0,
  first_name: 1,
  last_name: 2,
  job_title: 3,
  team_name: 5,
  start_date: 8
}

# amtwoundcare
SCHEMA6 = {
  email: 0,
  first_name: 1,
  last_name: 2,
  start_date: 8
}

SCHEMA7 = {
  first_name: 0,
  last_name: 1,
  email: 2,
  team_name: 3
}

SCHEMA8 = {
  first_name: 0,
  last_name: 1,
  email: 2,
  job_title: 3
}

SCHEMA9 = {
  email: 0,
  first_name: 1,
  last_name: 2,
  job_title: 3,
  team_name: 4
}

SCHEMA10 = {
  email: 0,
  first_name: 1,
  last_name: 2,
  job_title: 3,
  team_name: 4,
  start_date: 5,
  phone: 6
}

SCHEMAS = [SCHEMA1, SCHEMA2, SCHEMA3, SCHEMA4, SCHEMA5, SCHEMA6, SCHEMA7,SCHEMA8,SCHEMA9,SCHEMA10]

SCHEMA= SCHEMAS[schema]

#################################################
# DO NOT EDIT BELOW THIS LINE
#################################################
suffix = Rails.env.production? ? "" : ".not.real.tld"
domain = domain + suffix
sender_email = sender_email + suffix

csv = CSV.read(file, encoding: "iso-8859-1:UTF-8")
c = Company.where(domain: domain).first
sender = User.where(email: sender_email).first
raise "Could not finder sender: #{sender_email}" unless sender.present?

failed_entries = []

csv.shift # remove headers
csv.each do |row|
  email = row[SCHEMA[:email]].strip.downcase + suffix if row[SCHEMA[:email]].present?
  first_name = row[SCHEMA[:first_name]].strip if row[SCHEMA[:first_name]].present?
  last_name = row[SCHEMA[:last_name]].strip if row[SCHEMA[:last_name]].present?
  job_title = row[SCHEMA[:job_title]].strip if SCHEMA[:job_title].present? && row[SCHEMA[:job_title]].present?
  team_name = row[SCHEMA[:team_name]].strip if SCHEMA[:team_name].present? && row[SCHEMA[:team_name]].present?
  start_date = row[SCHEMA[:start_date]].strip if SCHEMA[:start_date].present? && row[SCHEMA[:start_date]].present?
  phone = row[SCHEMA[:phone]].strip if SCHEMA[:phone].present? && row[SCHEMA[:phone]].present?
  # debugger if email == ("SARAH.HUMINICKI@INVESTORSGROUP.COM"+suffix).downcase

  if start_date.present?
    begin
      # timearr = start_date.split("/")
      # timearr[2] = "20" + timearr[2] if twodigityear
      # start_date = Date.parse("#{timearr[2]}-#{timearr[0]}-#{timearr[1]}")
      start_date = DateTime.strptime("#{start_date} 00:00 PDT", date_format+" %H:%M %Z")
    rescue => e
      debugger; puts ""
    end
  end

  if team_name.present?
    team = c.teams.where(name: team_name).first_or_initialize
    if team.new_record?
      team.created_by_id = sender.id
      team.save
    end
  end

  if email.present?
    user = User.where(email: email).first
    puts "Finding user by email: #{email}"
  else
    user = c.users.where(first_name: first_name, last_name: last_name, network: domain).first
    puts "Finding user by first, last name: #{first_name} #{last_name}"
  end

  if user.blank?
    puts "User not found"
    if email.blank? 
      failed_entries << row
      next
    else 
      opts = {}
      if send_invitation
        puts "Inviting user by email: #{email}"
        user = sender.invite!(email, nil, company: c, skip_same_domain_check: true, bypass_disable_signups: true)
        user = user.first
      else
        puts "Adding user without invite: #{email}"
        user = sender.add_user_without_invite!(email, company: c, skip_same_domain_check: true, bypass_disable_signups: true)
      end

      # user is always added to network of their domain
      # so move to specified domain if necessary
      unless user.persisted?
        begin
          user.save!
        rescue => e
          debugger
          puts ""
        end
      end

      # if user.network != c.domain
      #   puts "Moving user from #{user.network} to #{c.domain}"
      #   user.move_company_to!(c) 
      # end

    end
  end

  if team.present? 
    if team.users.include?(user)
      puts "User: #{user.email} already on team: #{team.name}"
    else
      puts "Adding #{user.email} to #{team.name}"
      team.users << user
    end
  else
    puts "User: #{user.email} has no team name to be assigned"
  end

  attrs = {}
  attrs[:job_title] = job_title.humanize if job_title.present?
  attrs[:start_date] = start_date if start_date.present?
  attrs[:first_name] = first_name.humanize if first_name.present?
  attrs[:last_name] = last_name.humanize if last_name.present?
  attrs[:phone] = phone if phone.present?

  # attrs[:company_id] = c.id
  # attrs[:network] = c.domain
  begin
    user.assign_attributes(attrs)
  rescue => e
    debugger; puts ""
  end

  if user.changed?
    puts "Making the following changes: #{user.changes.inspect}"
    result = user.save
    puts "===> User was #{'not ' unless result}saved #{'because ' + user.errors.full_messages.join(' ') unless result}"
  else
    puts "There were no changes to make"
  end
  # separate out password from main attribute update to 
  # allow updating of attributes even if password is already
  # set which will cause update to fail(b/c need to include original pw)
  if default_password
    puts "Setting password..."
    user.password = default_password
    result = user.save
    if result
      user.verify_and_activate!
      puts "Password saved and user activated"
    else
      puts "Password could not be saved because #{user.errors.full_messages.join(' ')}"
    end
  end  
end

if failed_entries.present?
  puts "-------------------------------------"
  puts "Could not process the following rows: "
  failed_entries.each do |failure|
    puts failure.inspect
  end
else
  puts "Import Complete: processed #{csv.length} rows"
end

