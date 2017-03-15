require 'spec_helper'

def build_params
  hash = User.all.inject({}){|hash, user| 
    unless user.system_user?
      hash[user.to_param] = HashWithIndifferentAccess.new(user.attributes).slice(*BulkUserUpdater::UPDATEABLE_ATTRS)
      hash[user.to_param][:id] = user.id
    end
    hash
  }
  return HashWithIndifferentAccess.new(bulk_user_updater: hash)
end

describe BulkUserUpdater do
  let!(:user) { FactoryGirl.create(:company_admin) }
  let!(:user2) { FactoryGirl.create(:active_user, email: "#{FactoryGirl.generate(:count)}@#{user.network}") }

  let(:company) { user.company }
  let(:params) { build_params }
  let(:bulk_user_updater) { BulkUserUpdater.new(company, user) }

  context "when no records are changed" do

    it "should update" do
      expect(bulk_user_updater.update(params)).to be_true
      expect(bulk_user_updater.valid?).to be_true
      expect(bulk_user_updater.users_to_update.map(&:id)).to eq([])
    end
  end

  context "when changing name" do
    let(:new_name) { "Bobbbb" }

    before do
      params[:bulk_user_updater][user2.to_param][:first_name] = new_name
      params[:bulk_user_updater][user2.to_param][:update] = "1"
    end

    it "should update" do
      expect(params[:bulk_user_updater][user2.to_param][:first_name]).to eq(new_name)
      expect(bulk_user_updater.update(params)).to be_true
      expect(bulk_user_updater.valid?).to be_true
      expect(user2.reload.first_name).to eq(new_name)
      expect(bulk_user_updater.created_users).to eq([])
      expect(bulk_user_updater.updated_users).to eq([{id: user2.id, email: user2.email}])
    end
  end

  context "when changing email external domain" do
    let(:new_email) { "newemail@xyzxyz.com"}

    before do
      params[:bulk_user_updater][user2.to_param][:email] = new_email
      params[:bulk_user_updater][user2.to_param][:update] = "1"
    end

    it "should update" do
      expect(params[:bulk_user_updater][user2.to_param][:email]).to eq(new_email)
      expect(bulk_user_updater.update(params)).to be_true
      expect(bulk_user_updater.valid?).to be_true
      expect(user2.reload.email).to eq(new_email)
      expect(bulk_user_updater.created_users).to eq([])
      expect(bulk_user_updater.updated_users).to eq([{id: user2.id, email: user2.email}])
      expect(user2.network).to eq(company.domain)
      expect(user2.company_id).to eq(company.id)

    end
  end

  context "when changing network" do
    context "when network in family" do
      let!(:subcompany) { company.make_child_company!("#{company.domain}-Marketing") }
  
      before do
        params[:bulk_user_updater][user2.to_param][:network] = subcompany.domain
        params[:bulk_user_updater][user2.to_param][:update] = "1"
      end

      it "should save new network" do
        expect(params[:bulk_user_updater][user2.to_param][:network]).to eq(subcompany.domain)
        expect(bulk_user_updater.update(params)).to be_true
        expect(bulk_user_updater.valid?).to be_true
        expect(user2.reload.network).to eq(subcompany.domain)
        expect(bulk_user_updater.created_users).to eq([])
        expect(bulk_user_updater.updated_users).to eq([{id: user2.id, email: user2.email}])
      end
    end

    context "when network out of family" do
      let!(:external_company) { FactoryGirl.create(:company) }

      before do
        params[:bulk_user_updater][user2.to_param][:network] = external_company.domain
        params[:bulk_user_updater][user2.to_param][:update] = "1"
      end

      it "should save network" do
        expect(params[:bulk_user_updater][user2.to_param][:network]).to eq(external_company.domain)
        expect(bulk_user_updater.update(params)).to be_true
        expect(bulk_user_updater.valid?).to be_true
        expect(user2.reload.network).to eq(external_company.domain)
        expect(bulk_user_updater.created_users).to eq([])
        expect(bulk_user_updater.updated_users).to eq([{id: user2.id, email: user2.email}])
      end
    end
  end

  context "when modifying user and creating another user" do
    let(:new_name) { "Mary" }
    let(:new_user_attrs) { {first_name: "Jane", last_name: "Goodall", email: "jane@goodall.com", network: company.domain}}
    let(:random_id) { Time.now.to_f.to_s }

    before do
      params[:bulk_user_updater][user2.to_param][:first_name] = new_name
      params[:bulk_user_updater][user2.to_param][:update] = "1"
      params[:bulk_user_updater][random_id] = new_user_attrs
      params[:bulk_user_updater][random_id][:create] = "1"

    end

    it "should modify user and create other user" do
      expect(bulk_user_updater.update(params)).to be_true
      expect(bulk_user_updater.valid?).to be_true
      expect(user2.reload.first_name).to eq(new_name)
      expect(bulk_user_updater.updated_users).to eq([{id: user2.id, email: user2.email}])
      expect(bulk_user_updater.created_users.length).to eq(1)

      new_user = User.find(bulk_user_updater.created_users[0][:id])

      expect(bulk_user_updater.created_users).to eq([{id: new_user.id, email: new_user.email, :temporary_id=>nil}])
      expect(new_user.first_name).to eq(new_user_attrs[:first_name])
      expect(new_user.last_name).to eq(new_user_attrs[:last_name])
      expect(new_user.email).to eq(new_user_attrs[:email])
      expect(new_user.network).to eq(new_user_attrs[:network])
      expect(new_user.company_id).to eq(company.id)
    end

  end

  context "when adding external user with personal email account" do
    let(:new_user_attrs) { {first_name: "Jane", last_name: "Goodall", email: "jane@gmail.com"}}
    let(:random_id) { Time.now.to_f.to_s }
    before do
      params[:bulk_user_updater][random_id] = new_user_attrs
      params[:bulk_user_updater][random_id][:create] = "1"
    end

    it "should add user to proper network" do
      expect(bulk_user_updater.update(params)).to be_true
      expect(bulk_user_updater.valid?).to be_true

      new_user = User.find(bulk_user_updater.created_users[0][:id])
      expect(bulk_user_updater.created_users).to eq([{id: new_user.id, email: new_user.email, :temporary_id=>nil}])
      expect(new_user.first_name).to eq(new_user_attrs[:first_name])
      expect(new_user.last_name).to eq(new_user_attrs[:last_name])
      expect(new_user.email).to eq(new_user_attrs[:email])
      expect(new_user.network).to eq(company.domain)
      expect(new_user.company_id).to eq(company.id)

    end
  end
end