# bin/rake recognize:generate_daily_sample_data
require 'csv'
module SampleData
  class File
    attr_accessor :users, :recognitions, :start_date, :num_recognitions, :num_approvals
    def self.generate!(recognition_data_filename, user_data_filename, opts={})
      puts "Running SampleData::File.generate on #{Recognize::Application.config.host}"
      if Recognize::Application.config.host == "recognizeapp.com" || !Rails.configuration.local_config.has_key?('allow_sample_data_generation')
        puts "Exiting due to running on prod host or missing local.yml key: 'allow_sample_data_generation'"    
        return     
      end

      sample_data = self.new(recognition_data_filename, user_data_filename, opts)
      sample_data.create_users!
      sample_data.assign_teams!
      sample_data.create_recognitions!
      sample_data.create_approvals!
      return sample_data
    end

    def initialize(recognition_data_filename, user_data_filename, opts={})
      Rails.configuration.local_config['prevent_yammer_requests'] = true
      @recognition_data = CSV.open(recognition_data_filename).read
      @user_data = CSV.open(user_data_filename).read
      @num_users = @user_data.length
      @num_recognitions = opts[:num_recognitions] || 50
      @num_approvals = opts[:num_approvals] || 50
      @users = []
      @teams = []
      @recognitions = []
      @start_date = opts[:start_date] || Time.now.at_midnight
      @opts = opts
      @company = opts[:network] ? Company.where(domain: opts[:network]).first : nil
    end
  
    def create_approvals!
      # @num_approvals = (@recognitions.length*(@num_users-2)) / 2#halve it so we don't saturate with approvals and we get a random spread

      loop_since(start_date, range: num_approvals) do |day, datapoint|

        datapoint.times do |i|
          puts "Creating approval #{i}/#{datapoint}"          
          recognition = @recognitions[rand(@recognitions.length)]
          senderI, recipientI = @users.index(recognition.sender), @users.index(recognition.recipients.first) 
          rlist = (0..@num_users-1).sort_by{rand}.tap{|a| a.delete(senderI);a.delete(recipientI)}
          giver = @users[rlist.first]
          approval = RecognitionApproval.create!(recognition_id: recognition.id, giver_id: giver.id) unless RecognitionApproval.where(recognition_id: recognition.id, giver_id: giver.id).exists?
        end      

      end

    end
    
    def create_recognitions!
      rlist = (1..@num_users).sort_by{rand}
      loop_since(start_date, range: num_recognitions) do |day, datapoint|
        # @recognitions = (1..@num_recognitions).collect{|i| 
        @recognitions ||= []
        @recognitions << (1..datapoint).collect{|i| 
          Timecop.freeze(rand(1..17).minutes.from_now)

          puts "Creating recognition #{i}/#{datapoint} at #{Time.now}"
          senderI, recipientI = (0..@num_users-1).sort_by{rand}[0..1]#gen 2 unique numbers in the employee set
          badge = @company.company_badges[rand(@company.company_badges.count)]
          
          data = @recognition_data[(i % @recognition_data.length)]
          @users[senderI].recognize!(@users[recipientI], Badge.where(name: data[1]).first, data[0])
        }
      end
      @recognitions.flatten!
    end
    
    def assign_teams!
      @teams = @users[0].company.teams
      @users.each{|e| 
        set = e.company.teams.sort_by{rand}[0..rand(e.company.teams.length)]
        e.teams = set
      }      
    end
    
    def create_users!
      company = @company
      @user_data.each do |u|
        email, image_url = u
        prefix, default_network = email.split("@")

        if company.blank?
          # company = Company.from_email(email)
          # Company.where(name: company.name).first.destroy if Company.exists?(name: company.name)
          # company.save!
          company = Company.where(domain: email.split("@")[1]).first
          if company.blank?
            company = Company.from_email(email)
            company.save!
          end
        end
        
        puts "Creating users for #{@company.domain}"

        adjusted_email = "#{prefix}@#{@company.domain}"
        unless user = User.where(email: adjusted_email).first
          first_name, last_name = prefix.split(".")
          last_name ||= first_name == "Alex" ? "Grande" : "Philips" #hack
          puts "Creating user: #{adjusted_email}"
          user = FactoryGirl.create(:active_user, email: adjusted_email, company: company, first_name: first_name.humanize, last_name: last_name)
          user.save!
          user.verify!
          user.set_status!(:active)
        end

        if image_url.present?
          puts "setting image: #{image_url}"
          user.avatar.remote_file_url = image_url
          user.avatar.save!
        end

        @users << user
      end
    end

    def loop_since(startdate, opts={})
      date, index = startdate, 0
      current_time = Time.now
      numdays = (current_time - startdate) / 1.day

      if numdays > 1
        graphdata = Grapherator.new(numdays).generate!
      else
        graphdata = [rand(opts[:range])]
      end

      while(date < current_time)
        puts "Running loop for: #{date}"
        Timecop.freeze(date)
        yield(date, graphdata[index])
        date += 1.day
        index += 1
      end

      Timecop.return
    end
  end
  
  class Generator
    attr_accessor :domain, :employees, :recognitions
  
    def initialize(domain = "company#{FactoryGirl.generate(:count)}.com", num_employees=10, num_recognitions=20)
      User.send(:_create_system_user!)
      @domain = domain
      @num_employees = num_employees
      @num_recognitions = num_recognitions
    end

    def generate!
      #CREATE EMPLOYEES
      @employees = (1..@num_employees).collect{|i| FactoryGirl.create(:active_user, email: "user#{i.to_s+FactoryGirl.generate(:count)}@#{@domain}", first_name: "User#{i}", last_name: "Smith#{i}")}
      print "."
    
      #ASSIGN A RANDOM SET OF TEAMS TO EACH USER
      @teams = @employees[0].company.teams
      @employees.each{|e| 
        set = e.company.teams.sort_by{rand}[0..rand(e.company.teams.length)]
        e.teams = set
      }
      print "."
    
      #CREATE RECOGNITIONS
      rlist = (1..@num_employees).sort_by{rand}
      @recognitions = (1..@num_recognitions).collect{|i| 
        senderI, recipientI = (0..@num_employees-1).sort_by{rand}[0..1]#gen 2 unique numbers in the employee set
        badge = Badge.user_badges[rand(Badge.user_badges.count)]
        FactoryGirl.create(:recognition, sender: @employees[senderI], recipients: [@employees[recipientI]], badge: badge)
      }
      print "."

      #CREATE APPROVALS
      #you can approve any and all recognitions other than yours(sent or received)
      #so the total number of approvals is numRecognitions*(numUsers-2)
      @num_approvals = (@num_recognitions*(@num_employees-2)) / 2#halve it so we don't saturate with approvals and we get a random spread
      @num_approvals.times do |i|
        recognition = @recognitions[rand(@num_recognitions)]
        senderI, recipientI = @employees.index(recognition.sender), @employees.index(recognition.recipients[0]) 
        rlist = (0..@num_employees-1).sort_by{rand}.tap{|a| a.delete(senderI);a.delete(recipientI)}
        giver, count = @employees[rlist.first], 0
        while(recognition.participants.include?(giver) and (count < 100)) do
          giver = @employees[rand(@employees.length)]
          count += 1
        end

        debugger if count >= 100
        raise "could not find an appropriate giver" if count >= 100

        # puts "#{Time.now.to_s(:db)} - i: #{i} - #{recognition.recipients.collect{|r| r.id} + [recognition.sender_id]} -> #{giver.id}"
        approval = RecognitionApproval.create!(recognition_id: recognition.id, giver_id: giver.id) unless RecognitionApproval.where(recognition_id: recognition.id, giver_id: giver.id).exists?
      end
      print "."
    end
  end
end
