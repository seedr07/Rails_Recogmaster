require 'spec_helper'

describe Recognition do
  include RecognitionsHelper

  context "when sending recognitions" do
    before do
      @sender = FactoryGirl.create(:user)
      @recipient = FactoryGirl.create(:user, email: "2"+@sender.email)
      @badge = Badge.boss
    end

    it "should raise exception when there is no sender" do
      recognition = Recognition.new
      recognition.save.should be_false
      recognition.errors[:sender_id].should be_present
      recognition.errors[:sender_name].should be_present
      recognition.errors[:badge_id].should be_present
    end
    
    it "should require recipient, and a badge" do
      recognition = Recognition.new(sender: @sender)
      recognition.save.should be_false
      recognition.errors[:sender_name].should be_present
      recognition.errors[:badge_id].should be_present
    end
    
    it "should succeed when sender, recipient, and badge are present" do
      @recognition = Recognition.new(sender: @sender, recipients: [@recipient], badge: @badge, message: "Great Job!")
      @recognition.save.should be_true, @recognition.errors.full_messages.join(", ")
      @recognition.reload.is_public.should be_true
      @recognition.slug.should be_present
    end
    
    it "should not allow a recognition with the same slug" do
      @recognition = FactoryGirl.create(:recognition)
      @new_recognition = FactoryGirl.create(:recognition)
      @new_recognition.slug = @recognition.slug
      @new_recognition.save.should be_false
      @new_recognition.errors[:slug].should be_present
    end
    
    it "should allow sending of recognitions if recipient is in a different company" do
      company = FactoryGirl.create(:company)
      @recipient.move_company_to!(company)
      @recipient.reload
      @recipient.company_id.should == company.id

      @recognition = Recognition.new(sender: @sender, recipients: [@recipient], badge: @badge, message: "Great Job!")
      @recognition.save.should be_true
      @recognition.errors[:recipients].should_not be_present
      @recognition.sender_company.should be_present
      @recognition.recipients.first.company.should be_present
      (@recognition.sender_company.id != @recognition.recipients.first.company.id).should be_true

    end

    it "should allow sending of recognitions from the system user" do      
      system_user = User.system_user
      badge = Badge.on_fire
      recipient = FactoryGirl.create(:active_user)
      recipient.company_id.should_not == system_user.company_id # sanity check
      @recognition = Recognition.new(sender: system_user, recipients: [recipient], badge: badge, message: "You're on fire!")
      @recognition.save.should be_true, @recognition.errors.full_messages.join(", ")
      recipient.company_id.should_not == system_user.company_id
      @recognition.recipients.first.company_id.should_not == system_user.company_id
      @recognition.recipients.first.company_id.should == recipient.company_id
      @recognition.sender_company.last_recognition_sent_at.should be_nil
      @recognition.recipients.first.company.last_recognition_received_at.should be_nil
    end    

    it "should not allow sending of recognitions from and to the same person" do
      @recognition = Recognition.new(sender: @sender, recipients: [@sender], badge: @badge, message: "Great Job!")
      @recognition.save.should be_false
      @recognition.errors.count.should == 1
      @recognition.errors[:user_recipients].should be_present
    end
    
    it "should not allow sending of a system badge by a non system user" do
      badge = Badge.system_badges.first
      @recognition = Recognition.new(sender: @sender, recipients: [@recipient], badge: badge, message: "Great Job!")
      @recognition.save.should be_false
      @recognition.errors.count.should == 1
      @recognition.errors[:sender_name].should be_present      
    end
  end
  
  context "when sending recognitions to an email address" do
    before do
      @sender = FactoryGirl.create(:user)
      @initial_email_count = ActionMailer::Base.deliveries.count
      @recipient_email = "newuser#{FactoryGirl.generate(:count)}@#{@sender.company.domain}"
      @badge = Badge.boss      
      @recognition = Recognition.new(sender: @sender, recipient_emails: [@recipient_email], badge: @badge, message: "Great Job!")
      @recognition.save
      @new_email_count = ActionMailer::Base.deliveries.count
    end
    
    it "should not allow sending to a malformed email address" do
      @recognition = Recognition.new(sender: @sender, recipient_emails: ["xyz"], badge: @badge, message: "Great Job!")
      @recognition.save.should be_false
      @recognition.errors[:user_recipients].should be_present
    end
    
    it "should allow sending to an email in a different domain" do
      @initial_company_count = Company.count
      @initial_email_count = ActionMailer::Base.deliveries.count
      @initial_user_count = User.count
      @recognition = Recognition.new(sender: @sender, recipient_emails: ["someemail@someotherdomain.com"], badge: @badge, message: "Great Job!")
      @recognition.save
      @recognition.persisted?.should be_true
      @recognition.errors[:recipients].should be_blank
      @recognition.sender_company.should be_present
      @recognition.recipients.first.company.should be_present
      @recognition.sender_company.id.should_not == @recognition.recipients.first.company_id
      @recognition.recipients.first.verified?.should be_false
      @recognition.recognition_recipients.to_a{|rr| rr.recipient_company_id.present? && rr.recipient_network.present? }.should be_true
      
      User.count.should == @initial_user_count + 1
      Company.count.should == @initial_company_count + 1
      ActionMailer::Base.deliveries.count.should == @initial_email_count + 1
      ActionMailer::Base.deliveries.last.subject.should == "#{@recognition.sender.full_name} recognized you!"
    end
    
    it "should allow sending a recognition to an email within the same domain" do
      @initial_company_count = Company.count
      @initial_emails = ActionMailer::Base.deliveries.dup
      @initial_user_count = User.count
      @original_company_name = @sender.company.name
      @recognition = Recognition.new(sender: @sender, recipient_emails: ["someotheremail@#{@sender.network}"], badge: @badge, message: "Great Job!")
      @recognition.save.should be_true
      @recognition.errors[:recipients].should be_blank
      @recognition.sender_company.should be_present
      @recognition.recipients.first.company.should be_present
      @recognition.sender_company.id.should == @recognition.recipients.first.company.id
      @recognition.recognition_recipients.to_a{|rr| rr.recipient_company_id.present? && rr.recipient_network.present? }.should be_true

      expect(@sender.company.reload.name).to eq(@original_company_name)

      User.count.should == @initial_user_count + 1
      Company.count.should == @initial_company_count
      ActionMailer::Base.deliveries.count.should == @initial_emails.length + 1
      ActionMailer::Base.deliveries.last.subject.should == "#{@recognition.sender.full_name} recognized you!"
    end
    
    it "should create an unvalidated user for that email" do
      @recognition.reload
      @recognition.recipients.first.should be_kind_of(User)
      @recognition.recipients.first.should be_persisted
      @recognition.recipients.first.invited?.should be_false
      @recognition.recipients.first.invited_from_recognition?.should be_true
      @recognition.recipients.first.invited_by_id.should == @sender.id
      @recognition.recipients.first.invited_at.should be_kind_of(Time)
      @recognition.sender_company.last_recognition_sent_at.should_not be_nil
      @recognition.recipients.first.company.last_recognition_received_at.should_not be_nil
      @recognition.recognition_recipients.load{|rr| rr.recipient_company_id.present? && rr.recipient_network.present? }.should be_true
    end
    
    it "should send an special invitation to that user with the recognition" do
      @new_email_count.should == @initial_email_count + 1
    end
  end
  
  context "when sending a recognition to an email address of a user that is already in the system" do
    before do
      @sender = FactoryGirl.create(:active_user)
      @recipient = FactoryGirl.create(:active_user, email: "newuser123123123#{FactoryGirl.generate(:count)}@#{@sender.company.domain}")
      @badge = Badge.boss      
      @recognition = Recognition.new(sender: @sender, recipient_emails: [@recipient.email], badge: @badge, message: "Great Job!")
      @initial_email_count = ActionMailer::Base.deliveries.count
      @recognition.save
      @new_email_count = ActionMailer::Base.deliveries.count      
    end

    it "should persist the recognition" do
      @recognition.should be_persisted
      @recognition.recognition_recipients.load{|rr| rr.recipient_company_id.present? && rr.recipient_network.present? }.should be_true
    end
    
    it "should keep users as active users" do
      @sender.active?.should be_true
      @recipient.active?.should be_true
    end

    it "should send a normal Recognition email" do
      @new_email_count.should == @initial_email_count + 1
      @last_email = ActionMailer::Base.deliveries.last
      @last_email.subject.match(/#{@recognition.sender.full_name} recognized you/).should be_true
      @last_email.subject.match(/recognized you and wants you to join Recognize/).should be_false
    end
    
  end

  # AS determined on 5/20/2015 - wont solve this edge case right now
  # context "when sending recognitions to multiple email addresses that are part of domain that is not in the system" do
  #   let(:badge) { Badge.boss }
  #   let(:sender) { FactoryGirl.create(:user) }
  #   let(:recipient_domain) { "rcptdomain#{FactoryGirl.generate(:count)}.com"}
  #   let(:email1) { "newuser1-#{FactoryGirl.generate(:count)}@#{recipient_domain}"}
  #   let(:email2) { "newuser2-#{FactoryGirl.generate(:count)}@#{recipient_domain}"}
  #   let(:email3) { "newuser3-#{FactoryGirl.generate(:count)}@#{recipient_domain}"}

  #   it "should send recognition to all recipients" do
  #     recognition = Recognition.new(sender: sender, recipients: [email1, email2, email3], badge: badge, message: "Great Job!")
  #     expect{ 
  #       expect(recognition.save).to be_true
  #     }.to change{Recognition.count}.by(1)
  #   end
  # end
  
  context "when destroying a recognition" do
    before do
      @recognition = FactoryGirl.create(:recognition_with_approvals)
      (@recognition.approvals.size > 0).should be_true
      @recognition.destroy
    end
    
    it "should no longer be visible from normal queries" do
      Recognition.exists?(id: @recognition.id).should be_false
    end
    
    it "should be findable if need be" do
      Recognition.with_deleted.exists?(@recognition.id).should be_true
    end
    
    it "should set deleted at field" do
      @recognition.deleted_at.should_not be_nil
    end    
    
    it "should destroy recognition approvals" do
      @recognition.approvals.size.should == 0
    end
  end

  context "when testing factories" do
    it "should create a recognition from factory while assigning existing recipient users" do
      @user = FactoryGirl.create(:active_user)
      @recognition = FactoryGirl.build(:recognition, recipients: [@user])
      expect{
        @recognition.save
        @recognition.should be_persisted
        @recognition.errors.should be_empty        
      }.to change{Recognition.count}.by(1)
    end

  end

  context "when testing counters" do
    context "on recognitions" do
      before do
        @recognition = FactoryGirl.create(:recognition)
        @user = FactoryGirl.create(:active_user)
      end

      it "should have counters initialized properly" do
        @recognition.approvals_count.should == 0
        @user.given_recognition_approvals_count.should == 0
      end

      it "should increment and decrement approvals count when a recognition is approved and unapproved" do
        approval = @recognition.approvals.build(giver: @user)
        approval.save!

        @recognition.reload.approvals_count.should == 1
        @user.reload.given_recognition_approvals_count.should == 1

        approval.destroy

        @recognition.reload.approvals_count.should == 0
        @user.reload.given_recognition_approvals_count.should == 0
      end
    end

    context "on users" do
      before do
        @sender = FactoryGirl.create(:active_user)
        @recipient = FactoryGirl.create(:active_user)
      end

      it "should have counters initialized properly" do
        @sender.received_recognitions_count.should == 0
        @sender.sent_recognitions_count.should == 0
      end

      it "should increment and decrement recognition counters when a recognition is sent" do
        recognition = recognize!(@sender, @recipient)
        @sender.reload
        @recipient.reload

        @sender.received_recognitions_count.should == 1 # includes system badge
        @sender.sent_recognitions_count.should == 1
        @recipient.received_recognitions_count.should == 2
        @recipient.sent_recognitions_count.should == 0

        recognition.destroy
        @sender.reload
        @recipient.reload

        @sender.received_recognitions_count.should == 1 
        @sender.sent_recognitions_count.should == 0
        @recipient.received_recognitions_count.should == 1
        @recipient.sent_recognitions_count.should == 0

      end
    end

    context "on companies" do
      before do
        @company = FactoryGirl.create(:company_with_users)
        @company.reload
      end

      it "should have the counters initialized properly" do
        @company.sent_recognitions_count.should == 0
        @company.sent_user_recognitions_count.should == 0
        @company.received_recognitions_count.should == 1
        @company.received_user_recognitions_count.should == 0
      end

      it "should update counters when a recognition is sent from a user within the company" do
        sender = @company.users.first
        recipient = FactoryGirl.create(:user)
        recognition = recognize!(sender, recipient)

        @company.reload
        @company.sent_recognitions_count.should == 1
        @company.sent_user_recognitions_count.should == 1
        @company.received_recognitions_count.should == 1
        @company.received_user_recognitions_count.should == 0

        recognition.destroy

        @company.reload
        @company.sent_recognitions_count.should == 0
        @company.sent_user_recognitions_count.should == 0
        @company.received_recognitions_count.should == 1
        @company.received_user_recognitions_count.should == 0

      end

      it "should update counters when a recognition is received to a user within the company" do
        recipient = @company.users.first
        sender = FactoryGirl.create(:user)
        recognition = recognize!(sender, recipient)

        @company.reload

        @company.sent_recognitions_count.should == 0
        @company.sent_user_recognitions_count.should == 0
        @company.received_recognitions_count.should == 2
        @company.received_user_recognitions_count.should == 1

        recognition.destroy

        @company.reload
        @company.sent_recognitions_count.should == 0
        @company.sent_user_recognitions_count.should == 0
        @company.received_recognitions_count.should == 1
        @company.received_user_recognitions_count.should == 0

      end

      it "should update counters when a recognition is sent within the company" do
        recipient = @company.users.first
        sender = FactoryGirl.create(:user, email: "#{FactoryGirl.generate(:count)}@#{@company.domain}")
        recognition = recognize!(sender, recipient)

        @company.reload

        @company.sent_recognitions_count.should == 1
        @company.sent_user_recognitions_count.should == 1
        @company.received_recognitions_count.should == 2
        @company.received_user_recognitions_count.should == 1

        recognition.destroy

        @company.reload
        @company.sent_recognitions_count.should == 0
        @company.sent_user_recognitions_count.should == 0
        @company.received_recognitions_count.should == 1
        @company.received_user_recognitions_count.should == 0

      end

      it "should have accurate counters when recognition has multiple recipients" do 
        sender = @company.users.first
        recipientA = FactoryGirl.create(:user, email: "#{FactoryGirl.generate(:count)}@#{@company.domain}")
        recipientB = FactoryGirl.create(:user, email: "#{FactoryGirl.generate(:count)}@#{@company.domain}")

        recognition = recognize!(sender, [recipientA, recipientB])
        recognition.reload.recipients.length.should == 2

        @company.reload

        @company.sent_recognitions_count.should == 1
        @company.sent_user_recognitions_count.should == 1
        @company.received_recognitions_count.should == 3
        @company.received_user_recognitions_count.should == 2

        recognition.destroy

        @company.reload
        @company.sent_recognitions_count.should == 0
        @company.sent_user_recognitions_count.should == 0
        @company.received_recognitions_count.should == 1
        @company.received_user_recognitions_count.should == 0

      end

    end
  end

  context "when recognizing a team" do
    before do
      @company = FactoryGirl.create(:company_with_users)
      @company.reload

      @sender = @company.users.first
      @recipientA = FactoryGirl.create(:user, email: "A1#{FactoryGirl.generate(:count)}@#{@company.domain}")
      @recipientB = FactoryGirl.create(:user, email: "B1#{FactoryGirl.generate(:count)}@#{@company.domain}")
      @recipientC = FactoryGirl.create(:user, email: "C1#{FactoryGirl.generate(:count)}@#{@company.domain}")
      @team_members = [@recipientA, @recipientB, @recipientC]
      @team = @company.teams.first
      @team.users = @team_members
    end

    context "when team is passed in as object" do 
      it "should properly recognize team" do 

        recognition = recognize!(@sender, @team)
        recognition.reload
        expect(recognition.persisted?).to be_true
        expect(recognition.recipients.length).to eq(1)
        expect(recognition.recipients[0]).to eq(@team)

        expect(recognition.flattened_recipients).to eq(@team_members)
        recognition.recognition_recipients.each do |rr|
          expect(rr.team_id).to eq(@team.id)
          expect(rr.user_id).to be_present
        end
      end
    end

    context "when team is passed in as signature" do
      it "should properly recognize team" do 

        recognition = recognize!(@sender, "Team:#{@team.id}")
        recognition.reload
        expect(recognition.persisted?).to be_true
        expect(recognition.recipients.length).to eq(1)
        expect(recognition.recipients[0]).to eq(@team)

        expect(recognition.flattened_recipients.length).to eq(3)
        expect(recognition.flattened_recipients).to eq(@team_members)
        recognition.recognition_recipients.each do |rr|
          expect(rr.team_id).to eq(@team.id)
          expect(rr.user_id).to be_present
        end
      end
    end

    context "when recipients are both team and explicit users" do 
      it "should properly recognize team" do 
        user_on_team = @recipientA
        user_not_on_team = FactoryGirl.create(:user, email: "D1#{FactoryGirl.generate(:count)}@#{@company.domain}")
        user2_not_on_team = FactoryGirl.create(:user, email: "E1#{FactoryGirl.generate(:count)}@#{@company.domain}")

        recognition = recognize!(@sender, [@team, user_on_team, user_not_on_team, user2_not_on_team])
        recognition.reload
        expect(recognition.persisted?).to be_true
        expect(recognition.recognition_recipients.length).to eq(6) # 1 user is in team and called out explicity
        expect(recognition.user_recipients.length).to eq(5) # but user recipients should be uniq on the user
        expect(recognition.recipients.length).to eq(4) # but final result
        expect(recognition.recipients).to include(@team)
        expect(recognition.recipients).to include(user_on_team)
        expect(recognition.recipients).to include(user_not_on_team)
        expect(recognition.recipients).to include(user2_not_on_team)

        expect(recognition.flattened_recipients).to eq((@team_members+[user_on_team, user_not_on_team, user2_not_on_team]).uniq)
      end
    end

    context "when team has no users" do 
      let(:team) { @company.teams.detect{|t| t.users.empty?} }

      it "should not save recognition" do
        recognition = recognize!(@sender, team, dont_use_bang_save: true)
        expect(recognition.persisted?).to be_false
        expect(recognition.errors[:recipients]).to be_present

      end
    end

    context "when team has sender as a member" do
      it "should properly recognize team" do 
        user_on_team = @recipientA
        @team.users << @sender

        @team.reload
        expect(@team.users).to include(@sender)

        recognition = recognize!(@sender, [@team])
        recognition.reload
        expect(recognition.persisted?).to be_true
        expect(recognition.recognition_recipients.length).to eq(4) 
        expect(recognition.user_recipients.length).to eq(4) # but user recipients should be uniq on the user
        expect(recognition.recipients.length).to eq(1) # but final result
        expect(recognition.recipients).to include(@team)

        expect(recognition.flattened_recipients).to eq([@team_members,@sender].flatten)
      end
    end

  end

  describe 'Earning redeemable points' do
    let(:sender) { FactoryGirl.create(:active_user) }
    let(:recipient) { FactoryGirl.create(:active_user) }

    context "when company does not have rewards enabled" do
      before do
        recipient.company.update_column(:allow_rewards, false)        
      end

      it "does not increase redeemable points" do
        sender_redeemable_points = sender.redeemable_points
        sender_total_points = sender.total_points

        recipient_redeemable_points = recipient.redeemable_points
        recipient_total_points = recipient.total_points

        recognition = recognize!(sender, recipient)

        sender.reload
        recipient.reload

        expect(sender.total_points).to eq(sender_total_points + sender.company.point_values["sent_recognition_value"])
        expect(recipient.total_points).to eq(recipient_total_points + recognition.badge.points)

        expect(sender.redeemable_points).to eq(sender_redeemable_points)
        expect(recipient.redeemable_points).to eq(recipient_redeemable_points)

      end
    end

    context "when company has rewards enabled" do
      before do
        recipient.company.update_column(:allow_rewards, true)
      end

      it "increases redeemable points" do
        expect(recipient.company.allow_rewards?).to be_true

        sender_redeemable_points = sender.redeemable_points
        sender_total_points = sender.total_points

        recipient_redeemable_points = recipient.redeemable_points
        recipient_total_points = recipient.total_points

        recognition = recognize!(sender, recipient)

        sender.reload
        recipient.reload

        expect(sender.total_points).to eq(sender_total_points + sender.company.point_values["sent_recognition_value"])
        expect(recipient.total_points).to eq(recipient_total_points + recognition.badge.points)

        expect(sender.redeemable_points).to eq(sender_redeemable_points) # send does not have rewards enabled
        expect(recipient.redeemable_points).to eq(recipient_redeemable_points + recognition.badge.points)


      end      
    end
  end

  # TODO: re-enable these tests when recognizing recipients of different types
  #
  # context "when sending to multiple recipients of different types" do
  #   before do
  #     @sender = FactoryGirl.create(:active_user)
  #     @existing_users = (0..2).collect{FactoryGirl.create(:active_user)} #missing
  #     @recipients_from_signature = (0..2).collect{"User:#{FactoryGirl.create(:active_user).id}"} #missing
  #     @recipients_from_signature += (0..2).collect{"Company:#{FactoryGirl.create(:active_user).company.id}"} #success
  #     @users_from_email = (0..2).collect{FactoryGirl.generate(:email)} #success
  #     @recipients = @existing_users + @recipients_from_signature + @users_from_email
  #   end

  #   it "should save existing users as recipients" do
  #     params = {sender: @sender, message: "hello", badge: Badge.user_badges.last, recipients: @existing_users}
  #     @recognition = @sender.recognitions.new(params)

  #     expect{
  #       @recognition.save.should be_true, @recognition.errors.full_messages.to_sentence
  #     }.to_not raise_exception

  #     @recognition.recipients.length.should == @existing_users.length
  #     @existing_users.each do |u|
  #       u.reload.recognitions.include?(@recognition).should be_true
  #     end

  #   end

  #   it "should save recipients from signature as recipients" do
  #     params = {sender: @sender, message: "hello", badge: Badge.user_badges.last, recipients:@recipients_from_signature}
  #     @recognition = @sender.recognitions.new(params)

  #     expect{
  #       @recognition.save.should be_true, @recognition.errors.full_messages.to_sentence
  #     }.to_not raise_exception

  #     @recognition.recipients.length.should == @recipients_from_signature.length

  #     @recipients_from_signature.each do |r| 
  #       Recognition.find_recipient_from_signature(r).recognitions.include?(@recognition).should be_true
  #     end
  #   end

  #   it "should save recipients from existing users and from signature" do
  #     set = (@existing_users + @recipients_from_signature)
  #     params = {sender: @sender, message: "hello", badge: Badge.user_badges.last, recipients: set}
  #     @recognition = @sender.recognitions.new(params)

  #     expect{
  #       @recognition.save.should be_true, @recognition.errors.full_messages.to_sentence
  #     }.to_not raise_exception

  #     @recognition.recipients.length.should == set.length

  #     @recipients_from_signature.each do |r| 
  #       Recognition.find_recipient_from_signature(r).recognitions.include?(@recognition).should be_true
  #     end
  #   end

  #   it "should save recognition with all the different types of recipients" do
  #     params = {sender: @sender, message: "hello", badge: Badge.user_badges.last, recipients: @recipients}
  #     @recognition = @sender.recognitions.new(params)
      
  #     expect{
  #       @recognition.save.should be_true, @recognition.errors.full_messages.to_sentence
  #     }.to_not raise_exception

  #     @recognition.reload.recipients.length.should == @recipients.length
  #     @existing_users.each do |u|
  #       u.reload.recognitions.include?(@recognition).should be_true
  #     end

  #     @recipients_from_signature.each do |r| 
  #       Recognition.find_recipient_from_signature(r).recognitions.include?(@recognition).should be_true
  #     end

  #     @users_from_email.each do |u|
  #       User.exists?(email: u).should be_true
  #       User.find_by_email(u).recognitions.include?(@recognition).should be_true
  #     end
  #   end
  # end
end
