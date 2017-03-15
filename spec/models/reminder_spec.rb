require 'spec_helper'

describe Reminder do

  THRESHOLDS = {
    users_who_have_not_sent_invitations_nor_recognitions: 72.hours,
    users_who_have_invited_but_not_recognized_anyone: 72.hours,
    users_who_are_inactive: 3.weeks,
    users_who_have_not_verified_and_need_to_be_warned: 1.week,
    users_who_have_not_verified_and_need_to_be_disabled: 1.week,
    companies_to_be_destroyed: 1.week
  }

  # add one day to all the thresholds so that we exceed it when creating sample data
  THRESHOLDS.each {|k,v| THRESHOLDS[k] = (v+1.day).ago}

  context "when working with a Reminder" do 

    subject { Reminder.new }
    
    it { should validate_presence_of :user_id }
    it { should belong_to :user }
  end

  context "when marking an email as sent" do
    before {@user = FactoryGirl.create(:active_user)}

    context "for a user without an existing reminder association" do
      before do
        Reminder.mark_sent!(@user, :no_invites_and_no_recognitions_reminder)
        @reminder = Reminder.find_by_user_id(@user.id)
      end

      it "should create the reminder association" do
        @reminder.should be_present
      end
      
      it "should have a timestamp for the email sent" do
        @reminder.no_invites_and_no_recognitions_reminder_sent_at.should be_present
        @reminder.no_invites_and_no_recognitions_reminder_sent_at.should be_kind_of(Time)
        @reminder.invited_but_no_recognitions_reminder_sent_at.should be_blank
        @reminder.inactive_user_reminder_sent_at.should be_blank
      end
    end
    
    context "for a user with an existing reminder association" do
      before do
        @user.create_reminder
        Reminder.mark_sent!(@user, :inactive_user_reminder)
        @reminder = Reminder.find_by_user_id(@user.id)
      end

      it "should create the reminder association" do
        @reminder.should be_present
      end
      
      it "should have a timestamp for the email sent" do
        @reminder.inactive_user_reminder_sent_at.should be_present
        @reminder.inactive_user_reminder_sent_at.should be_kind_of(Time)
        @reminder.invited_but_no_recognitions_reminder_sent_at.should be_blank
        @reminder.no_invites_and_no_recognitions_reminder_sent_at.should be_blank
      end
      
    end
  end
  
  # context "when testing pulling of users" do
  #   before(:all) do
  #     DatabaseCleaner.strategy = nil
  #     User.send(:_create_system_user!)
  #     # Company.delete_all("id <> #{Company.find_by_domain("recognizeapp.com").id}")
  #     @users, @companies = create_sample_data
  #   end
    
  #   after(:all) do
  #     init_db!
  #     DatabaseCleaner.strategy = :truncation, {:except => tables_not_to_truncate}
  #   end

  #   context "from set of users who have no invites and no recognitions" do
  #     before do
  #       @expected_users = @users[:users_with_no_invites_and_no_recognitions_sent_without_reminder]
  #       @found_users = Reminder.users_who_have_not_sent_invitations_nor_recognitions
  #     end
      
  #     it "should return a set the proper set of users" do
  #       @found_users.length.should == @expected_users.length
  #       @found_users.map(&:id).should == @expected_users.map(&:id)
  #     end
  #   end
    
  #   context "from set of users who have invited but have not recognized" do
  #     before do
  #       @expected_users = @users[:users_with_invites_but_no_recognitions_without_reminder]
  #       @found_users = Reminder.users_who_have_invited_but_not_recognized_anyone
  #     end

  #     it "should return a set the proper set of users" do
  #       @found_users.length.should == @expected_users.length
  #       @found_users.map(&:id).should == @expected_users.map(&:id)
  #     end

  #   end
    
  #   context "from set of users who have not been active for 3 weeks" do
  #     before do
  #       @expected_users = @users[:users_who_have_been_inactive_for_3_weeks_without_reminder]
  #       @found_users = Reminder.users_who_are_inactive
  #     end

  #     it "should return a set the proper set of users" do
  #       @found_users.length.should == @expected_users.length
  #       @found_users.map(&:id).should == @expected_users.map(&:id)
  #     end

  #   end
    
  #   context "from set of users who have not verified for more than a week from creation and have not been reminded" do
  #     before do
  #       @expected_users = @users[:users_who_have_not_verified_without_any_reminder]
  #       @found_users = Reminder.users_who_have_not_verified_and_need_to_be_warned_first_time
  #     end

  #     it "should return a set the proper set of users" do
  #       @found_users.length.should == @expected_users.length
  #       @found_users.map(&:id).should == @expected_users.map(&:id)
  #     end      
  #   end 

  #   context "from set of users who have not verified and have been warned first time" do
  #     before do
  #       @expected_users = @users[:users_who_have_not_verified_and_first_reminder_has_been_sent]
  #       @found_users = Reminder.users_who_have_not_verified_and_need_to_be_warned_second_time
  #     end

  #     it "should return a set the proper set of users" do
  #       @found_users.length.should == @expected_users.length
  #       @found_users.map(&:id).should == @expected_users.map(&:id)
  #     end      
  #   end      

  #   context "from set of users who have not verified and have been warned second time" do
  #     before do
  #       @expected_users = @users[:users_who_have_not_verified_and_second_reminder_has_been_sent]
  #       @found_users = Reminder.users_who_have_not_verified_and_need_to_be_warned_third_time
  #     end

  #     it "should return a set the proper set of users" do
  #       @found_users.length.should == @expected_users.length
  #       @found_users.map(&:id).should == @expected_users.map(&:id)
  #     end      
  #   end   

  #   context "from set of users who have not verified and have been warned third time" do
  #     before do
  #       @expected_users_with_noone_else = @users[:users_who_have_not_verified_and_third_reminder_has_been_sent_and_nobody_else_has_verified]
  #       @expected_users_with_verified_coworkers = @users[:users_who_have_not_verified_and_third_reminder_has_been_sent_and_others_have_verified]
  #       @expected_users = @expected_users_with_noone_else+@expected_users_with_verified_coworkers
  #       @found_users = Reminder.users_who_have_not_verified_and_need_to_be_disabled
  #     end

  #     it "should return a set the proper set of users" do
  #       @found_users.length.should == @expected_users.length
  #       @found_users.map(&:id).should == @expected_users.map(&:id)
  #     end      

  #     context "and testing disabling user and/or destroying company" do
  #       before(:all) do
  #         @found_users = Reminder.users_who_have_not_verified_and_need_to_be_disabled
  #         Reminder.disable_unverified_users(@found_users)
  #       end

  #       it "should have disabled companies where there are no users who verified" do
  #         if @expected_users_with_noone_else.length <= 0
  #           Rails.logger.debug "Reminder Spec: User: #{@users.inspect}" 
  #           puts "Reminder Spec: User: #{@users.inspect}"
  #         end
  #         (@expected_users_with_noone_else.length > 0).should be_true
  #         @expected_users_with_noone_else.each do |user|
  #           user.reload
  #           user.disabled?.should be_true
  #           user.company.disabled?.should be_true
  #         end
  #       end

  #       it "should not have disabled companies which have a coworker who verified" do
  #         if @expected_users_with_verified_coworkers.length <= 0
  #           Rails.logger.debug "Reminder Spec: User: #{@users.inspect}" 
  #           puts "Reminder Spec: User: #{@users.inspect}"
  #         end

  #         (@expected_users_with_verified_coworkers.length > 0).should be_true
  #         @expected_users_with_verified_coworkers.each do |user|
  #           user.reload
  #           user.disabled?.should be_true
  #           user.company.disabled?.should be_false
  #         end
  #       end
  #     end
  #   end  

  #   context "from set of companies about to be disabled" do
  #     before do
  #       @expected_companies = @companies[:companies_who_have_been_disabled]
  #       @found_companies = Reminder.companies_to_be_destroyed
  #     end

  #     it "should return a set the proper set of users" do
  #       @found_companies.length.should == @expected_companies.length
  #       @found_companies.map(&:id).should == @expected_companies.map(&:id)
  #     end      
            
  #   end   
  # end
end

def create_sample_data
  print ("c")
  users = {
    users_with_no_invites_and_no_recognitions_sent_without_reminder: [],
    users_with_no_invites_and_no_recognitions_sent_with_reminder: [],
    users_with_invites_but_no_recognitions_without_reminder: [],
    users_with_invites_but_no_recognitions_with_reminder: [],
    users_with_invites_and_recognitions: [],
    users_who_have_been_inactive_for_3_weeks_without_reminder: [],
    users_who_have_been_inactive_for_3_weeks_with_reminder: [],
    users_who_have_not_verified_without_any_reminder: [],
    users_who_have_not_verified_and_first_reminder_has_been_sent: [],
    users_who_have_not_verified_and_second_reminder_has_been_sent: [],
    users_who_have_not_verified_and_third_reminder_has_been_sent_and_nobody_else_has_verified: [],
    users_who_have_not_verified_and_third_reminder_has_been_sent_and_others_have_verified: []
  }
  
  companies = {
    companies_who_have_been_disabled: []
  }
  
  #user with no invites and no recognitions without reminder sent
  rand(10).times{users[:users_with_no_invites_and_no_recognitions_sent_without_reminder] << create_user_without_invitations_and_recognitions}
  print ("r")

  #user with no invites and no recognitions with reminder sent
  rand(10).times{user = create_user_without_invitations_and_recognitions
  Reminder.mark_sent!(user, :no_invites_and_no_recognitions_reminder)
  users[:users_with_no_invites_and_no_recognitions_sent_with_reminder] << user}
  print ("e")
  
  #user with invites but no recognitions
  rand(10).times{users[:users_with_invites_but_no_recognitions_without_reminder] << create_user_with_invites_but_no_recognitions}
  print ("a")
  
  #user with invites and no recognitions with reminder sent
  rand(10).times{user = create_user_with_invites_but_no_recognitions
  Reminder.mark_sent!(user, :invited_but_no_recognitions_reminder)
  users[:users_with_invites_but_no_recognitions_with_reminder] << user}
  print ("t")

  #user with invites and recognitions
  rand(10).times{users[:users_with_invites_and_recognitions] << create_user_with_invites_and_recognitions}
  print ("i")

  #user who has been inactive for 3 weeks without reminder sent
  rand(10).times{users[:users_who_have_been_inactive_for_3_weeks_without_reminder] << create_user_who_has_been_inactive_for_3_weeks}
  print ("n")

  #user who has been inactive for 3 weeks with reminder sent
  rand(10).times{user = create_user_who_has_been_inactive_for_3_weeks
  Reminder.mark_sent!(user, :inactive_user_reminder)
  users[:users_who_have_been_inactive_for_3_weeks_with_reminder] << user}
  print ("g")

  #users who have not verified without reminder
  rand(10).times{users[:users_who_have_not_verified_without_any_reminder] << create_user_who_has_not_verified}
  print (" ")

  #users who have verified with first reminder
  rand(10).times{user = create_user_who_has_not_verified
    Timecop.freeze(THRESHOLDS[:users_who_have_not_verified_and_need_to_be_warned])
    Reminder.mark_sent!(user, :has_not_verified_first_warning)
    Timecop.return
    users[:users_who_have_not_verified_and_first_reminder_has_been_sent] << user
  }
  print ("d")

  #users who have verified with second reminder
  rand(10).times{user = create_user_who_has_not_verified
    Timecop.freeze(THRESHOLDS[:users_who_have_not_verified_and_need_to_be_warned])
    Reminder.mark_sent!(user, :has_not_verified_first_warning)
    Timecop.freeze(THRESHOLDS[:users_who_have_not_verified_and_need_to_be_warned])
    Reminder.mark_sent!(user, :has_not_verified_second_warning)
    Timecop.return
    users[:users_who_have_not_verified_and_second_reminder_has_been_sent] << user
  }
  print ("a")

  #users who have verified with third reminder and nobody else have verified
  rand(10).times{user = create_user_who_has_not_verified
    Timecop.freeze(THRESHOLDS[:users_who_have_not_verified_and_need_to_be_warned])
    Reminder.mark_sent!(user, :has_not_verified_first_warning)
    Timecop.freeze(THRESHOLDS[:users_who_have_not_verified_and_need_to_be_warned])
    Reminder.mark_sent!(user, :has_not_verified_second_warning)
    Timecop.freeze(THRESHOLDS[:users_who_have_not_verified_and_need_to_be_warned])
    Reminder.mark_sent!(user, :has_not_verified_third_warning)
    Timecop.return
    users[:users_who_have_not_verified_and_third_reminder_has_been_sent_and_nobody_else_has_verified] << user
  }
  print ("t")

  #users who have verified with third reminder and others have verified
  rand(10).times{user = create_user_who_has_not_verified
    FactoryGirl.create(:active_user, email: "a#{FactoryGirl.generate(:count)}@#{user.company.domain}")
    Timecop.freeze(THRESHOLDS[:users_who_have_not_verified_and_need_to_be_warned])
    Reminder.mark_sent!(user, :has_not_verified_first_warning)
    Timecop.freeze(THRESHOLDS[:users_who_have_not_verified_and_need_to_be_warned])
    Reminder.mark_sent!(user, :has_not_verified_second_warning)
    Timecop.freeze(THRESHOLDS[:users_who_have_not_verified_and_need_to_be_warned])
    Reminder.mark_sent!(user, :has_not_verified_third_warning)
    Timecop.return
    users[:users_who_have_not_verified_and_third_reminder_has_been_sent_and_others_have_verified] << user
  }
  print ("a")

  #companies who have been disabled
  rand(10).times{
    companies[:companies_who_have_been_disabled] << create_disabled_company
  }
  print (".")
  return users, companies
end

def create_user_without_invitations_and_recognitions
  user = FactoryGirl.create(:active_user)
  user.update_attribute(:created_at, THRESHOLDS[:users_who_have_not_sent_invitations_nor_recognitions])
  user.invited_users.should be_empty
  user.sent_recognitions.should be_empty
  return user
end

def create_user_with_invites_but_no_recognitions
  user = FactoryGirl.create(:active_user)
  user.invited_users.should be_empty
  user.sent_recognitions.should be_empty
  user.update_attribute(:created_at, THRESHOLDS[:users_who_have_invited_but_not_recognized_anyone])
  user.invite!("poop")
  user.reload.invited_users.should_not be_empty
  user.sent_recognitions.should be_empty
  return user
end

def create_user_with_invites_and_recognitions
  user = FactoryGirl.create(:active_user)
  other_user = FactoryGirl.create(:active_user, email: "a#{Time.now.to_f.to_s}@#{user.company.domain}")
  user.invited_users.should be_empty
  user.sent_recognitions.should be_empty
  user.invite!("poop")
  user.recognize!(other_user, Badge.user_badges.first, "word up homey")
  user.reload.invited_users.should_not be_empty
  user.sent_recognitions.should_not be_empty
  return user
end

def create_user_who_has_been_inactive_for_3_weeks
  user = FactoryGirl.create(:active_user)
  user.last_login_at = THRESHOLDS[:users_who_are_inactive]
  user.save!
  FactoryGirl.create(:recognition, sender: user, recipient_emails: ["a#{FactoryGirl.generate(:count)}@#{user.company.domain}"])
  return user
end

def create_user_who_has_not_verified
  user = FactoryGirl.create(:user)
  user.update_attribute(:created_at,  THRESHOLDS[:users_who_have_not_verified_and_need_to_be_warned])
  return user
end

def create_disabled_company
  company = FactoryGirl.create(:company)
  company.update_attribute(:disabled_at, THRESHOLDS[:companies_to_be_destroyed])
  return company
end