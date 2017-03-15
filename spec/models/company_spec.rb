require 'spec_helper'

describe Company do
  include BadgeHelper
  include RecognitionsHelper  

  context "when creating a company" do
    it "initializes point values" do    
      company = FactoryGirl.build(:company)
      expect(company.save).to be_true
      Report::User::DEFAULT_POINTS.each do |key, value|
        expect(company.send(key)).to eq(value)
      end
    end

    it "allows does not allow updating of point values via mass assignment" do
      company = FactoryGirl.create(:company)
      expect{
        company.update_attributes({sent_recognition_value: 100, received_approval_value: 200})      
      }.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end

    it "allows updating of points values via special writer method" do
      company = FactoryGirl.create(:company)
      company.update_point_values({sent_recognition_value: 100, received_approval_value: 200})
      expect(company.errors.count).to eq(0)
      company.reload
      expect(company.sent_recognition_value).to eq(100)
      expect(company.received_approval_value).to eq(200)
      expect(company.sent_approval_value).to eq(Report::User::DEFAULT_POINTS[:sent_approval_value])
      
    end

    it "does not allow updating of points to bad or null value" do
      company = FactoryGirl.create(:company)

      # blank
      company.update_point_values({sent_recognition_value: nil})
      expect(company.errors.count).to eq(1)

      # negative
      company.update_point_values({sent_recognition_value: -1})
      expect(company.errors.count).to eq(1)

      # non-numeric
      company.update_point_values({sent_recognition_value: "abc"})
      expect(company.errors.count).to eq(1)

      #valid: 0
      company.update_point_values({sent_recognition_value: 0})
      expect(company.errors.count).to eq(0)

      company.reload
      expect(company.sent_recognition_value).to eq(0)
      expect(company.received_approval_value).to eq(Report::User::DEFAULT_POINTS[:received_approval_value])
      expect(company.sent_approval_value).to eq(Report::User::DEFAULT_POINTS[:sent_approval_value])
      
    end
  end

  context "when testing teams" do
    before do
      @company = FactoryGirl.create(:company)
    end
    
    it "should test if a company has a team" do
      teams = Team.default_set
      @company.has_team?(teams.first).should be_true
      @company.has_team?("12312ASDWasdfasdflkj23423r").should be_false
    end
  end
  
  context "after creating a company" do
    before do
      @company = FactoryGirl.create(:company)
    end

    it "should create a default set of teams" do
      @company.reload
      @company.teams.length.should == Team.default_set.length
      @company.teams.each do |t|
        Team.default_set.include?(t.name).should be_true
      end
    end
    
  end
  
  context "when disabling a company" do
    before do
      @company = FactoryGirl.create(:company)
      @company.disabled?.should be_false
      @company.disable!
    end

    it "should set state to disabled" do
      @company.disabled?.should be_true
    end
    
    it "should not send a notification email" do
      expect{
        @company.disable!
      }.to_not change{ActionMailer::Base.deliveries.count}.by(1)
    end
    
  end
  
  context "when destroying a company" do
    before do
      @company = FactoryGirl.create(:company_with_users)
      (@company.users.size > 0).should be_true
      @company.destroy
    end

    it "should no longer be visible from normal queries" do
      Company.exists?(id: @company.id).should be_false
    end
    
    it "should be findable if need be" do
      Company.with_deleted.exists?(@company.id).should be_true
    end
    
    it "should set deleted at field" do
      @company.deleted_at.should_not be_nil
    end    
    
    it "should destroy recognition approvals" do
      @company.users.size.should == 0
    end
    
  end

  context "when working with custom badges" do
    before do
      @company = FactoryGirl.create(:company_with_users)
    end

    context "and enabling them for a company" do

      it "should create new badges for the company when enabling" do
        with_sandboxed_badges do 
          @company.badges.should be_empty
          @company.custom_badges_enabled?.should be_false
          expect {
            @company.enable_custom_badges!       
          }.to change{Badge.count}.by(4)
          @company.custom_badges_enabled?.should be_true
          @company.badges.length.should == 4
        end
      end 
    end
  end #working with custom badges

  context "when working with sub and parent companies" do
    before do 
      @parent_company = FactoryGirl.create(:company_with_users)
    end

    it "should have a parent company and children companies assigned" do
      company = FactoryGirl.create(:company_with_users)
      company.update_attribute(:parent_company_id, @parent_company.id)
      company.reload
      @parent_company.reload
      company.parent_company.should == @parent_company
      @parent_company.child_companies.length.should == 1
      @parent_company.child_companies[0].should == company
    end

    it "should not allow company with same domain if parent is set" do
      company = FactoryGirl.build(:company_with_users, domain: @parent_company.domain, parent_company: @parent_company)      
      expect{
        company.save.should be_false
      }.to_not raise_exception
    end

    it "should not care about matching user emails to domain if company is a child company" do
      user = FactoryGirl.create(:active_user)
      company = @parent_company.make_child_company!("Foobazi")
      user.company_id = company.id
      user.network = company.domain
      user.save.should be_true
    end

    it "should allow easy creation of child companies" do
      expect {
        name = "childco"
        @first_user = @parent_company.users.first
        @other_user = FactoryGirl.create(:active_user, email: "#{FactoryGirl.generate(:count)}@#{@parent_company.domain}")

        @parent_company.reload

        company = @parent_company.make_child_company!(name) 
        recognize!(@parent_company.users.first, @other_user)

        @parent_company.reload
        company.reload

        company.parent_company.should == @parent_company
        @parent_company.reload.child_companies[0].should == company
        expect(company.domain).to eq("#{@parent_company.domain}-#{name}")
        expect(company.name).to eq(name)

        #ensure all counter caches are reset
        expect(company.users.size).to_not eq(@parent_company.users.size)
        expect(company.sent_recognitions.size).to_not eq(@parent_company.sent_recognitions.size)
        expect(company.received_recognitions.size).to_not eq(@parent_company.received_recognitions.size)
        expect(company.received_user_recognitions_count).to_not eq(@parent_company.received_user_recognitions_count)

      }.to change{Company.count}.by(1)
    end

    context "when parent company has custom badges" do
      before do
        @parent_company.enable_custom_badges!
        @badge = @parent_company.company_badges.first
        @badge.update_columns(short_name: "New Custom Badge", points: 999, restricted: true)
      end

      it "should create child company with clones of those custom badges" do
        company = @parent_company.make_child_company!("Foobazi") 
        expect(company).to be_persisted
        expect(company.company_badges.length).to eq(@parent_company.company_badges.length)
        cloned_custom_badge = company.company_badges.detect{|b| b.short_name == "New Custom Badge" }
        expect(cloned_custom_badge).to be_present
        expect(cloned_custom_badge.points).to eq(999)
        expect(cloned_custom_badge.restricted).to be_true
      end
    end

  end

  context "when adding external users" do
    let!(:inviter) { FactoryGirl.create(:user) }
    let(:company) { inviter.company }

    context "from hash" do 
      let(:user_attributes) { {first_name: "Peter", last_name: "Phi", email: "peter@peter.com"}}
  
      it "should add user to the appropriate company" do
        expect{company.add_external_user!(inviter, user_attributes)}.to change{company.users.size}.by(1)

        user = User.where(email: user_attributes[:email]).first
        expect(user.company_id).to eq(company.id)
        expect(user.roles.length).to eq(1)
        expect(user.roles.first).to eq(Role.employee)
      end
    end

    context "from csv" do 
      let(:csv) { File.join(Rails.root, "db/sample_external_import_data.csv") }
  
      it "should add user to the appropriate company" do
        orig_emails = ActionMailer::Base.deliveries.dup
        expect{ ExternalUserImporter.from_csv(inviter, csv) }.to change{company.users.size}.by(2)
        users = User.last(2)
        users.each do |user|
          expect(user.invited_by).to eq(inviter)
          expect(user.invited_at).to be_present
        end

        expect(ActionMailer::Base.deliveries.length).to eq(orig_emails.length + 2)
        (ActionMailer::Base.deliveries - orig_emails).each do |email|
          expect(email.subject).to match(/invites you/)
        end

      end

    end

  end
end
