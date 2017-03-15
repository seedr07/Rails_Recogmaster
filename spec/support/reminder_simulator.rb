require 'csv'
class ReminderSimulator

  def self.run(span=30, opts={})
    results = {}
    opts[:run_in_transaction] ||= true

    if opts[:dry_run]
      #force no sending of emails
      Rails.logger.info "DryRun: changing delivery method to test"
      old_delivery_method = ActionMailer::Base.delivery_method
      ActionMailer::Base.delivery_method = :test
    else
      Rails.logger.info "Simulator running without DryRun - using #{ActionMailer::Base.delivery_method } "      
    end
    
    setup!(opts)
    
    Timecop.freeze
    results[Time.now.to_formatted_s(:db)] = ReminderSimulator.new.run!(opts)
    
    span.times do
      Timecop.freeze(Time.now.in(1.day))
      results[Time.now.to_formatted_s(:db)] = ReminderSimulator.new.run!(opts)
    end
    
    csv = self.render_results(results, opts)
    
    if opts[:email]
      ActionMailer::Base.delivery_method = old_delivery_method if opts[:dry_run]
      SystemNotifier.reminder_simulation(File.read("simulation.csv")).deliver
    end
    
  ensure
    teardown!(opts)
    ActionMailer::Base.delivery_method = old_delivery_method if opts[:dry_run]
    Timecop.return
  end

  def self.setup!(opts={})
    ActiveRecord::Base.connection.increment_open_transactions if opts[:run_in_transaction]
    ActiveRecord::Base.connection.begin_db_transaction if opts[:run_in_transaction]
    ActiveRecord::Base.connection.tables.each do |t|
      ActiveRecord::Base.connection.execute("ALTER TABLE #{t} DISABLE KEYS;")
    end

    ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS = 0;")
    ActiveRecord::Base.connection.execute("SET UNIQUE_CHECKS = 0;")
    ActiveRecord::Base.connection.execute("SET AUTOCOMMIT = 0;")
    
  end
  
  def self.teardown!(opts={})
    Rails.logger.info "Tearing down..."
    ActiveRecord::Base.connection.rollback_db_transaction if opts[:run_in_transaction]
    ActiveRecord::Base.connection.decrement_open_transactions if opts[:run_in_transaction]
    ActiveRecord::Base.connection.tables.each do |t|
      ActiveRecord::Base.connection.execute("ALTER TABLE #{t} ENABLE KEYS;")
    end
    ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS = 1;")
    ActiveRecord::Base.connection.execute("SET UNIQUE_CHECKS = 1;")
    ActiveRecord::Base.connection.execute("COMMIT;")
  end
  
  def self.render_results(results, opts={})
    # 3/12/13 => [
    #             [:users_who_have_not_sent_invitations_nor_recognitions, [u1, u2, u3]], [:users_who_have_invited_but_not_recognized_anyone, [u4,u5]]
    #            ]
    
    new_set = {}
    
    results.each do |date, date_results|
      new_set[date] = []
      date_results.each do |set|
        action = set[0]
        set[1].each do |o|
          Rails.logger.debug "--------Rendering: #{o.inspect}"
          
          #its either a user or a company
          if o.kind_of?(User)
            users = o.company.users.with_deleted
            num_verified_users = users.select{|c| c.verified?}.length

            label = "#{o.email}"
            label << "(#{o.verified? ? 'verified' : 'unverified'})"
            label << "(#{o.company_admin? ? 'admin' : 'employee'})"
            label << "(#{num_verified_users}/#{users.size}  users verified)"
            label << "(#{o.company.sent_user_recognitions_count} sent recognitions)"
            label << "(#{o.company.received_user_recognitions_count} received recognitions)"
          else
            users = o.users.with_deleted
            num_verified_users = users.select{|c| c.verified?}.length
            label = "#{o.domain}"
            label << "(#{num_verified_users}/#{users.length} users verified)"
            label << "(#{o.sent_user_recognitions_count} sent recognitions)"
            label << "(#{o.received_user_recognitions_count} received recognitions)"
          end          
           
          new_set[date] << "#{label} - #{action}"
        end
      end
    end
    
    rows = [new_set.keys]

    values = new_set.values
    max = values.max{|r1, r2| r1.length <=> r2.length}.length
    
    values.each {|r| max.times{|i| r[i] ||= nil}}
    rows += values.transpose
    
    csv = CSV.open("simulation.csv", "w") do |csv|
      rows.each do |r|
        csv << r
      end
    end
    
    return csv
  end
  
  def run!(opts={})
    return Reminder::Process.daily
    # reminder_process = Reminder::Process.new(opts)
    # 
    # return reminder_process.run!
    #ActionMailer::Base.deliveries.collect{|d| "#{d.from.join(',')} - #{d.to.join(',')} - #{d.subject}"}
  end
end
