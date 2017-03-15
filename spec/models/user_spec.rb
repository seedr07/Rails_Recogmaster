require 'spec_helper'

describe User do
  context "when attempting to create a user" do

    context "with proper parameters" do
      before(:each) do
        @initial_user_count = User.count
        @params = valid_params
        @user = User.new @params
        @user.save!
      end

      it "should add a record to the database" do
        expect{@user.reload}.to_not raise_exception
        User.count.should == @initial_user_count + 1
      end

      it "should not have any errors" do
        @user.errors.empty?.should be_true
      end

      it "should have a slug" do
        # we add "1" here because when we run email to slug again
        # after already having a slug, it will generate a uniq slug
        # by adding 1 to it
        (@user.slug+"1").should == @user.email_to_slug
      end

      it "should validate" do
        user = User.new valid_params
        user.valid?.should be_true
      end

      it "should default to pending signup completion state" do
        @user.pending_signup_completion?.should be_true
      end

      it "should have a company associated with it" do
        @user.company.should_not be_blank
      end

      it "should have a single recognition, the new user badge" do
        @user.recognitions.count.should == 1
        @user.recognitions[0].badge.should == Badge.ambassador
        @user.recognitions[0].recipients.length.should == 1
        @user.recognitions[0].recipients[0].should == @user
      end

      it "should not verify user even if its a new domain" do
        #valid params always returns an email with a new domain
        #unless otherwise specified
        @user.verified?.should be_false
      end

    end

    context "with missing a parameter" do
      before(:each) do
        @params = valid_params
        @params.delete(:email)
        @user = User.new @params
      end

      it "should not add a record to the database" do
        expect{@user.save}.to_not change(User, :count).by(1)
      end

      it "should have errors on the missing parameter" do
        @user.save
        @user.errors.empty?.should be_false
        @user.errors[:email].should_not be_blank
      end

      it "should not validate" do
        @user.valid?.should be_false
      end

    end

    context "when email is just a number" do
      before do
        @params = valid_params
        @prefix = "1"
        @params[:email] = "#{@prefix}@#{@params[:email].split('@')[1]}"
        @user = User.new @params
      end

      it "should add a record to the database but massage slug" do
        expect{@user.save}.to change(User, :count).by(1)
        @user.reload.slug.should == "user-#{@prefix}"
      end

      it "should not have errors on the missing parameter" do
        @user.save
        @user.errors.empty?.should be_true
        @user.errors[:email].should be_blank
      end

      it "should not validate" do
        @user.valid?.should be_true
      end
    end

    context "when email has 2 @ symbols in it" do
      before do
        @params = valid_params
        @params[:email] += "@"+@params[:email].split("@").last
        @user = User.new @params
      end

      it "should not add a record to the database" do
        expect{@user.save}.to_not change(User, :count).by(1)
      end

      it "should have errors on the missing parameter" do
        @user.save
        @user.errors.empty?.should be_false
        @user.errors[:email].should_not be_blank
      end

      it "should not validate" do
        @user.valid?.should be_false
      end

    end

    context "when changing password" do
      before(:each) do
        @user = FactoryGirl.create(:user)
      end

      it "should have an error on the password field when missing original password" do
        @user.password = "newpassword123"
        @user.save.should be_false
        @user.errors[:original_password].should_not be_blank
      end

      it "should have an error on the password field when original password is provided but is not correct" do
        @user.original_password = "notoriginal"
        @user.password = "newpassword123"
        @user.save.should be_false
        @user.errors[:original_password].should_not be_blank
      end

      it "should change password and save user object when original password is provided and is correct" do
        @user.original_password = "abcdef"
        @user.password = "newpassword123"
        @user.save.should be_true
      end

    end

    context "when working with recognitions" do

      subject { User.new }

      it { should have_many :received_recognitions }
      it { should have_many :sent_recognitions }

    end

    context "when email is from a blacklisted domain" do
      include EmailBlacklist
      before do
        FactoryGirl.create(:company, name: "Users", domain: "users") unless Company.exists?(domain: "users")
        @params = valid_params
        @blacklist_domain = email_blacklist[rand(email_blacklist.length-1)]
        @email = "bob@#{@blacklist_domain}"
        @params[:email] = @email
        @user = User.new @params
        @user.save
      end

      it "should save user and not have errors on email" do
        @user.persisted?.should be_true
        @user.errors[:email].should_not be_present
      end

      it "should have company and network set to 'users'" do
        @user.network.should == "users"
        @user.company.domain.should == "users"
      end
    end

    context "when email is from a domain that exists in the system" do
      before do
        @existing_user = FactoryGirl.create(:user)
        domain = @existing_user.email.split("@")[1]
        @user = User.new(valid_params.merge(email: "email@#{domain}"))
        @user.save
      end

      it "should have user as unverified" do
        @user.verified?.should be_false
      end
    end
  end

  context "when dealing with roles" do

    subject { User.new }

    it "should have many user_roles" do
      should have_many :user_roles
    end

    it "should have many roles and return an array" do
      expect(subject.roles).to be_kind_of Array
    end

    it "should have a default user role of Employee" do
      @user = FactoryGirl.build(:user)
      @user.save
      @user.respond_to?(:employee?)
      @user.employee?.should be_true
    end

    it "should persist adding a role to a user" do
      @user = FactoryGirl.create(:user)
      @role = Role.admin

      expect{
        @user.roles << @role
        @user.save!
      }.to change(UserRole, :count).by(1)
      @user.reload.roles.include?(@role).should be_true
    end

    it "should give a company admin role to a user from a new domain" do
      @user = FactoryGirl.create(:user)
      @user.company_admin?.should be_true
    end

    it "should not give a company admin role to a new user from an existing domain" do
      @first_user = FactoryGirl.create(:user)
      domain = @first_user.company.domain
      @user = FactoryGirl.build(:user)
      @user.email = "email#{FactoryGirl.generate(:count)}@#{domain}"
      @user.save
      @user.persisted?.should be_true
      @user.company_admin?.should be_false
    end
  end

  context "when dealing with invitations" do
    before do
      @user = FactoryGirl.create(:user)
      @num_invitations = 4
      @invited_users = []

      @num_invitations.times do |i|
        invited_user = FactoryGirl.create(:user, email: i.to_s+@user.email)
        invited_user.update_attribute(:invited_at, Time.now)
        invited_user.update_attribute(:invited_by_id, @user.id)
        invited_user.reload
        @invited_users << invited_user
      end
    end

    it "should be able see all users a user has invited" do
      @user.invited_users.should be_kind_of(ActiveRecord::Associations::CollectionProxy)
      @user.invited_users.length.should == @num_invitations
      @invited_users.each do |invited_user|
        @user.invited_users.map(&:id).include?(invited_user.id).should be_true
      end
    end

    it "should be able to see who invited a particular user" do
      @invited_users.each do |invited_user|
        invited_user.invited_by.should be_kind_of(User)
        invited_user.invited_by.id.should == @user.id
      end
    end

    context "and actually sending invite" do
      before do
        @old_company_last_user_created_at = @user.company.last_user_created_at
        sleep 0.1
        Timecop.freeze
        @invite_emails = (1..@num_invitations).collect{|i| "emailstub#{i}"}
        @initial_email_count = ActionMailer::Base.deliveries.length
        @new_users = @user.invite!(@invite_emails)
      end

      after do
        Timecop.return
      end

      it "should create users" do
        @new_users.should be_kind_of(Array)
        @new_users.each_with_index do |new_user, i|
          new_user.persisted?.should be_true
          new_user.email.should == @invite_emails[i]+"@"+@user.company.domain
        end
      end

      it "should send invitation emails" do
        ActionMailer::Base.deliveries.length.should == @initial_email_count + @num_invitations
      end

      it "should set invited_by and invited_at attributes and user should not be verified" do
        @new_users.each do |new_user|
          new_user.invited_by.should == @user
          new_user.invited_at.should be_present
          new_user.verified?.should be_false
        end
      end

      it "should set the company last user created_at field" do
        c = @user.company.reload.last_user_created_at
        c.to_i.should_not == @old_company_last_user_created_at.to_i
        c.to_i.should == Time.now.to_i
      end
    end
  end

  context "and sending invites from yammer" do
    before do
      @user = FactoryGirl.create(:active_user)
      @initial_email_count = ActionMailer::Base.deliveries.length
      @number = 10
      @domain = @user.company.domain
      @yammer_users = (1..@number).inject({}){|h, i| h.merge(generate_yammer_user(@domain))}
      @new_users = @user.invite_from_yammer!(@yammer_users)
    end

    it "should have created #{@number} users" do
      @new_users.length.should == @number
    end

    it "should have sent #{@number} emails" do
      ActionMailer::Base.deliveries.length.should == @initial_email_count + @number
    end
  end

  context "when calculating points" do
    before do
      @user1 = FactoryGirl.create(:user).reload
      @domain = @user1.company.domain
      @user2 = FactoryGirl.build(:user)
      @user2.email = "email-B#{FactoryGirl.generate(:count)}@#{@domain}"
      @user2.save.should be_true
      @starting_points = @user1.total_points
    end

    it "should increase points by #{Report::User::DEFAULT_POINTS[:sent_recognition_value]} for each sent recognition when the user sends a recognition" do
      # @user1.stub(:sent_recognitions).and_return([1,2,3])
      @user1.recognize!(@user2, Badge.user_badges.first, "whatever")
      @user1.reload.total_points.should == @starting_points + (1*Report::User::DEFAULT_POINTS[:sent_recognition_value])
    end

    it "should increase points by badge point value for each received recognition" do
      starting_recognition_count = @user1.recognitions.length
      recognition = FactoryGirl.create(:recognition, recipients: [@user1], sender: @user2)
      @user1.reload
      @user1.total_points.should == ((starting_recognition_count)*recognition.badge.points)
    end

    it "should increase points by #{Report::User::DEFAULT_POINTS[:received_approval_value]} for each approval of each received recognition" do
      @user1.received_recognitions.each{|r| RecognitionApproval.create!(giver: @user2, recognition: r)}
      @user1.reload
      @user1.total_points.should == @starting_points + (@user1.received_recognitions.length*Report::User::DEFAULT_POINTS[:received_approval_value])
    end

    it "should increase points by #{Report::User::DEFAULT_POINTS[:sent_approval_value]} for each approval given out" do
      user2_starting_points = @user2.total_points
      @user1.received_recognitions.each{|r| RecognitionApproval.create!(giver: @user2, recognition: r)}
      @user2.reload
      @user2.total_points.should == user2_starting_points + (@user1.received_recognitions.length*Report::User::DEFAULT_POINTS[:sent_approval_value])
    end

  end

  context "when dealing with email settings" do
    before do
      @user = FactoryGirl.create(:user)
    end

    context "and checking default settings" do
      it "should always have a default user setting for every user obj" do
        @user.email_setting.should be_kind_of(EmailSetting)
      end

      it "should be false for the global unsubscribe" do
        @user.email_setting.global_unsubscribe.should be_false
      end

      it "should be true for all invididual settings" do
        EmailSetting.settings.each do |setting|
          if (setting != :daily_updates)
            @user.email_setting.send(setting).should be_true
          else
            @user.email_setting.send(setting).should_not be_true
          end
        end
      end
    end

  end

  context "when disabling a user" do
    before do
      @user = FactoryGirl.create(:user)
      @user.disabled?.should be_false
    end

    it "should set state to disabled" do
      @user.disable!
      @user.disabled?.should be_true
      @user.status.should == :disabled
    end

    it "should not send a notification email" do
      expect {
        @user.disable!
      }.to_not change{ActionMailer::Base.deliveries.count}.by(1)
    end

  end

  context "when testing recognitions sent or received since a certain time" do
    before do
      @user = FactoryGirl.create(:active_user)
      @user2 = FactoryGirl.create(:active_user, email: "asdfsadf@#{@user.company.domain}")

      Timecop.freeze(2.months.ago)
      3.times{@user.recognize!(@user2, Badge.user_badges[1], "great stuff")}
      5.times{@user2.recognize!(@user, Badge.user_badges[2], "awesome sauce")}

      Timecop.return
      Timecop.freeze(2.weeks.ago)
      3.times{@user.recognize!(@user2, Badge.user_badges[1], "great stuff")}
      5.times{@user2.recognize!(@user, Badge.user_badges[2], "awesome sauce")}

      Timecop.return
      3.times{@user.recognize!(@user2, Badge.user_badges[1], "great stuff")}
      5.times{@user2.recognize!(@user, Badge.user_badges[2], "awesome sauce")}

    end

    it "should return the proper number of sent recognitions for each user" do
      @user.recognitions_sent_since(1.year.ago).length.should == 9
      @user2.recognitions_sent_since(1.year.ago).length.should == 15

      @user.recognitions_sent_since(1.month.ago).length.should == 6
      @user2.recognitions_sent_since(1.month.ago).length.should == 10

      @user.recognitions_sent_since(1.week.ago).length.should == 3
      @user2.recognitions_sent_since(1.week.ago).length.should == 5
    end

    it "should return the proper number of received recognitions for each user" do
      @user.recognitions_received_since(1.year.ago).length.should == 16#16 b/c system badge
      @user2.recognitions_received_since(1.year.ago).length.should == 9

      @user.recognitions_received_since(1.month.ago).length.should == 11
      @user2.recognitions_received_since(1.month.ago).length.should == 6

      @user.recognitions_received_since(1.week.ago).length.should == 6
      @user2.recognitions_received_since(1.week.ago).length.should == 3
    end

  end

  context "when testing creating a user with a domain same base domain to an existing domain but has different tld" do
    before do
      @first_user = FactoryGirl.create(:active_user)
      @user = FactoryGirl.build(:active_user, email: "#{FactoryGirl.generate(:count)}@#{@first_user.company.slug}.io")
    end

    it "should allow creation" do
    end
  end

  context "when testing read features" do
    before do
      @user = FactoryGirl.create(:active_user)
    end

    it "should not have any read features" do
      @user.has_read_features.should be_nil
    end

    it "should allow setting a new feature" do
      @user.has_read_feature!(:whatever)
      @user.reload
      @user.has_read_features.should be_kind_of(Hash)
      @user.has_read_features[:whatever].should be_true
    end
  end

  context "when testing counter caches" do
    before do
      @user = FactoryGirl.create(:active_user)
    end

    it "should not have a last_user_created_at set on the company" do
      @user.company.last_user_created_at.should be_nil
    end

    before "and inviting someone" do
      @user.invite!("blahasdasd")
    end

    it "should have a last_user_created_at set on the company" do
      @user.company.reload.last_user_created_at.should be_kind_of(Time)
    end
  end

  context "when destroying a user" do
    before do
      @user = FactoryGirl.create(:active_user)
      @reminder  = Reminder.find_or_create_by(user_id: @user.id)
      @user.teams = @user.company.teams
      (@user.recognitions.size > 0).should be_true
      (@user.teams.size > 0).should be_true
      @teams = Team.find(@user.teams.pluck(:id))
      @user.destroy
    end

    it "should no longer be visible from normal queries" do
      User.exists?(id: @user.id).should be_false
    end

    it "should be findable if need be" do
      User.with_deleted.exists?(@user.id).should be_true
    end

    it "should set deleted at field" do
      @user.deleted_at.should_not be_nil
    end

    it "should destroy recognition approvals" do
      @user.recognitions.size.should == 0
    end

    it "should destroy association to team " do
      @teams.each do |t|
        UserTeam.exists?(team_id: t.id, user_id: @user.id).should be_false
        UserTeam.with_deleted.exists?(team_id: t.id, user_id: @user.id).should be_true
      end
    end

    it "should destroy association to reminder " do
      Reminder.exists?(user_id: @user.id).should be_false
      Reminder.with_deleted.exists?(user_id: @user.id).should be_true
    end

    it "should destroy association to email setting" do
      EmailSetting.exists?(user_id: @user.id).should be_false
      EmailSetting.with_deleted.exists?(user_id: @user.id).should be_true
    end
  end

  context "when testing recognition graph" do
    before do
      @user = FactoryGirl.create(:active_user)
    end

    it "should by default have no recognition graph for new users" do
      @user.recognition_graph.should be_kind_of Hash
      @user.recognition_graph.should be_empty
    end

    context "when a cross company recognition is sent from this user" do
      before do
        @recipient_email = "abc@abc.com"
        @recognition = Recognition.create(sender: @user, recipient_emails: [@recipient_email], badge: Badge.user_badges.last, message: "hello")
        @recognition.should be_persisted, @recognition.errors.full_messages.to_sentence

        # add a secondary user to the recipients company
        @secondary_user = FactoryGirl.create(:active_user, email: "def@abc.com")
      end

      it "should have the recipient in the recognition graph" do
        @user.reload.recognition_graph.keys.include?(@recognition.recipients[0].email).should be_true
      end

      it "should not have any other users in the recipients company" do
      end

    end

    context "when a cross company recognition is sent to this user" do
      before do
        @sender = FactoryGirl.create(:active_user)
        @recognition = Recognition.create(sender: @sender, recipient_emails: [@user.email], badge: Badge.user_badges.last, message: "hello")
        @recognition.should be_persisted

        # add a secondary user to the senders company
        @secondary_user = FactoryGirl.create(:active_user, email: "def@#{@sender.network}")

      end

      it "should have the sender in the recognition graph" do
        @user.reload.recognition_graph.keys.include?(@sender.email).should be_true
      end

      it "should not have any other users in the senders company" do
        @user.reload.recognition_graph.keys.include?(@secondary_user.email).should be_false
      end

      it "should not have its own user in its external connections" do
        @user.reload.recognition_graph.keys.include?(@user.email).should be_false
      end

    end
  end

  context "when changing companies" do
    before do
      @user = FactoryGirl.create(:active_user)
      @company = FactoryGirl.create(:company_with_users)
    end

    it "should allow changing companies and set appropriate network" do
      @user.move_company_to! @company
      @user.reload.company.should == @company
      @user.network.should == @company.domain
    end

    it "should update all the recognitions sender company when changing companies" do
      set = []
      5.times{set << FactoryGirl.create(:recognition, sender: @user)}

      @old_company = @user.company
      @user.reload.sent_recognitions.length.should == 5
      @user.company.sent_recognitions.count.should == 5
      @company.sent_recognitions.count.should == 0

      @user.move_company_to! @company

      @user.reload.sent_recognitions.length.should == 5
      @user.company.sent_recognitions.count.should == 0
      @company.reload.sent_recognitions.count.should == 0
      @company.recognitions.count.should == 1
      @old_company.reload.sent_recognitions.count.should == 5
      @old_company.recognitions.length.should == 6


    end
  end

  context "when creating teams" do
    let(:user) { FactoryGirl.create(:active_user)}
    let(:team_names) { ["Skunk", "Advertising"] }

    before {
      user.create_team!(name: team_names[0])
      user.create_team!(name: team_names[1])
    }

    it "assigns teams" do
      expect(user.reload.teams.map(&:name)).to eq(team_names)
      user.teams.each do |team|
        expect(team.reload.managers).to include(user)
        expect(team.reload.creator).to eq(user)
      end
    end

  end

  context "when adding a director" do
    let(:company_admin) { FactoryGirl.create(:active_user) }
    let(:user) { FactoryGirl.create(:active_user, email: "#{FactoryGirl.generate(:count)}@#{company_admin.network}") }

    it "should ensure that user has company admin role as well" do
      # need to test again secondary user, as first user for co will be company admin
      expect(user.roles).to eq([Role.employee])
      user.roles << Role.director
      user.reload
      expect(user.roles).to include(Role.director)
      expect(user.roles).to include(Role.company_admin)
    end
  end

  context 'when adding a phone number' do
    let(:user) { FactoryGirl.create(:active_user) }

    before do
      Recognize::Application.stub(twilio_client: Recognize::Application.twilio_test_client)
      user.phone = phone
      user.save
    end

    shared_examples_for :unsaveable_number do
      it "should not save number " do
        expect(user.valid?).to be_false
        expect(user.reload.phone).to_not eq(phone)
      end
    end

    shared_examples_for :saveable_number do
      it "should save number " do
        exp_phone = defined?(expected_phone) ? expected_phone : "+13476229000"
        expect(user.valid?).to be_true
        expect(user.reload.phone).to eq(exp_phone)
      end
    end

    context 'when valid' do
      let(:phone) { "+13476229000" }
      it_behaves_like :saveable_number
    end

    context 'when basic international phone number' do
      let(:phone) { "+551155256325" }
      let(:expected_phone) { "+551155256325" }
      it_behaves_like :saveable_number
    end

    context 'when formatted in us national standard with hyphens' do
      let(:phone) { "1-347-622-9000" }
      it_behaves_like :saveable_number
    end

    context 'when formatted in us national standard with parentheses' do
      let(:phone) { "1 (347) 622-9000" }
      it_behaves_like :saveable_number
    end

    context 'when its a bunch of letters' do
      let(:phone) { "(xxx) xxx-9000" }
      it_behaves_like :unsaveable_number
    end

  end

  def valid_params
    FactoryGirl.attributes_for(:user)
  end

  def generate_yammer_user(domain, opts={})
    id = FactoryGirl.generate(:count)
    return {
      id => HashWithIndifferentAccess.new(
      "invite"=>"true",
      "first_name"=>"Alex#{id}",
      "last_name"=>"Grande#{id}",
      "full_name"=>"Alex Grande#{id}",
      "email"=>"alex#{id}@#{domain}",
      "avatar"=>"https://mug0.assets-yammer.com/mugshot/images/48x48/B-Fx5nhdT5WtStsHdBSzHVG-qMZ44B03")
    }
  end
end


