require 'spec_helper'

describe Badge do

  def valid_attrs
    # FactoryGirl.attributes_for(:badge)
    { "name" => "funny",
      "short_name" => "Funny",
      "long_name" => "Funny Badge",
      "image" => File.open(Rails.root.join("app/assets/images/badges/200/cooperative.png")),
      "description" => "description" }
  end

  context "when working with a Badge" do

    subject { Badge.new }

    it { should validate_presence_of :short_name }

  end

  describe "#nominations" do
    it 'returns set of all Badges that are nomination badges' do

    end
  end

  describe "#is_nomination" do
    it 'returns true if badge is nomination badge' do
    end
  end

  context "when working with an unsaved badge with valid attributes" do
    before(:each) do
      @badge = Badge.new(valid_attrs)
    end
    after(:each) { Badge.delete_all("id=#{@badge.id}") if @badge and @badge.id }

    it { @badge.should be_valid }
    it { @badge.save.should be_true }
  end

  context "when working with dynamic interrogators" do
    before do
      @badge = Badge.leader
    end

    it "should return true when asking if a new user badge is a leader badge" do
      @badge.leader?.should be_true
    end

    it "should return false when asking if a leader badge is any other type of badge other than a leader badge" do
      @badge.boss?.should be_false
    end

  end

  context "when working with custom badges" do

    before(:all) do
      AttachmentUploader.storage :file
      @company = FactoryGirl.create(:company)
    end
    after(:each) { Badge.delete_all("id=#{@badge.id}") if @badge and @badge.id and @badge.company_id }

    it "should allow creating a new badge with a company and image" do
      opts = {
          company: @company,
          short_name: " Cool Corporate Value",
          description: "This shows how cool our company is",
          image: File.open(Rails.root.join("app/assets/images/badges/200/cooperative.png"))
      }
      begin
        @badge = Badge.create(opts)
      rescue Exception => e
        puts "Caught exception! - #{e.inspect}"
      end
      @badge.should be_persisted, @badge.errors.full_messages.to_sentence
      @badge.reload.image.should be_kind_of BadgeUploader
      @badge.name.should == :cool_corporate_value
      @badge.custom?.should be_true
    end

    it "should not allow destroy of non custom badges" do
      @badge = Badge.boss
      expect {
        @badge.destroy
      }.to_not change { Badge.count }
    end

    it "should allow destruction of a custom badge" do
      @badge = FactoryGirl.create(:custom_badge)
      expect {
        @badge.destroy
      }.to change { Badge.count }.by(-1)
    end

    it "should allow cloning of a custom badge" do
      name = "Cool custom badge3"
      @badge = FactoryGirl.create(:custom_badge)
      @badge.points = 999
      @badge.restricted = true
      @badge.short_name = name
      @badge.company.stub(in_family?: true)

      cloned_custom = @badge.clone_to_custom
      cloned_custom.company_id = 1
      expect(cloned_custom).to be_valid
      expect(cloned_custom.save).to be_true
      expect(cloned_custom.points).to eq(999)
      expect(cloned_custom.restricted).to be_true
      expect(cloned_custom.short_name).to eq(name)
      expect(cloned_custom.id).to_not eq(@badge.id)
      expect(cloned_custom.created_at).to_not eq(@badge.created_at)
      expect(cloned_custom.updated_at).to_not eq(@badge.updated_at)
      cloned_custom.destroy!
    end

    context("#grant_permission_to_roles(action, new_roles)") do
      it "assigns 'action' permission to new_roles" do
        role = @company.company_roles.create!(name: "Executive")
        badge = @company.badges.find_or_create_by!(short_name: "Thumbs up")
        badge.grant_permission_to_roles(:send, [role])

        authz = Authz::Manager.new(role.reload)
        expect(authz.can?(:send, badge)).to be_true
      end
    end

    it "#roles_with_permission(action) should find all roles that have 'action' permission" do
      role = @company.company_roles.create!(name: "Executive")
      badge = @company.badges.create!(short_name: "Thumbs up")

      badge.grant_permission_to_roles(:send, [role])
      expect(badge.roles_with_permission(:send)).to eql([role])
    end
  end
end
