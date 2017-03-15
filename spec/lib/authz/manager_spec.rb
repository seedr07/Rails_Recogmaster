require "spec_helper"
require "pp"

describe Authz::Manager do
  let!(:company) { Company.create!(name: "Corp-X", domain: "domination.com") }
  let!(:role) { company.company_roles.create!(name: "Executive") }
  let!(:role_badge) { company.badges.create!(short_name: "RoleBadge") }
  let!(:user_badge) { company.badges.create!(short_name: "UserBadge") }
  let!(:user) { User.create!(first_name: "Joe", last_name: "Smith", email: "joe@domination.com") }


  before(:each) do
    Permission.create!(target_action: "delete", target_class: "Badge", target_id: role_badge.id)
    permission = Permission.create!(target_action: "send", target_class: "Badge", target_id: role_badge.id)
    role.grant(permission)

    Permission.create!(target_action: "delete", target_class: "Badge", target_id: user_badge.id)
    permission = Permission.create!(target_action: "send", target_class: "Badge", target_id: user_badge.id)
    user.grant(permission)
  end

  context ".can?(action, object)" do
    it "returns true if role has permission" do
      authz = Authz::Manager.new(role)
      expect(role.permissions.size).to eql(1)
      expect(authz.can?(:send, role_badge)).to be_true
    end

    it "returns false if role does not have permission" do
      authz = Authz::Manager.new(role)
      expect(role.permissions.size).to eql(1)
      expect(authz.can?(:delete, role_badge)).to be_false
    end

    it "returns true if user has role permission" do
      user.company_roles.push(role)

      authz = Authz::Manager.new(user)
      expect(user.permissions.size).to eql(2)
      expect(authz.can?(:send, role_badge)).to be_true
    end

    it "returns false if user does not have role permission" do
      user.company_roles.push(role)

      authz = Authz::Manager.new(user)
      expect(user.permissions.size).to eql(2)
      expect(authz.can?(:delete, role_badge)).to be_false
    end

    it "returns true if user has user permission" do
      authz = Authz::Manager.new(user)
      expect(user.permissions.size).to eql(1)
      expect(authz.can?(:send, user_badge)).to be_true
    end

    it "returns false if user does not have user permission" do
      user.direct_permissions.delete_all

      authz = Authz::Manager.new(user)
      expect(user.permissions.size).to eql(0)
      expect(authz.can?(:send, user_badge)).to be_false
    end
  end

  context ".find(target_action, target_class)" do
    it "returns badges where role has :send permissions" do
      authz = Authz::Manager.new(role)
      badges = authz.find(:send, Badge)

      expect(badges.count).to eql(1)
      expect(badges.first.class).to eql(Badge)
      expect(badges.first.id).to eql(role_badge.id)
    end

    it "returns badges where user has :send permissions" do
      authz = Authz::Manager.new(user)
      badges = authz.find(:send, Badge)

      expect(badges.count).to eql(1)
      expect(badges.first.class).to eql(Badge)
      expect(badges.first.id).to eql(user_badge.id)
    end
  end

  context ".grant(action, object)" do
    it "grants a permission to a role" do
      role.direct_permissions.delete_all

      authz = Authz::Manager.new(role)
      authz.grant(:send, role_badge)

      expect(role.permissions.count).to eql(1)
      expect(authz.can?(:send, role_badge)).to be_true
    end

    it "grants a permission to a user" do
      user.direct_permissions.delete_all

      authz = Authz::Manager.new(user)
      authz.grant(:send, user_badge)

      expect(user.permissions.count).to eql(1)
      expect(authz.can?(:send, user_badge)).to be_true
    end
  end

  context ".revoke(action, object)" do
    it "revokes a permission from a role" do
      authz = Authz::Manager.new(role)
      authz.revoke(:send, role_badge)

      expect(role.permissions.count).to eql(0)
      expect(authz.can?(:send, role_badge)).to be_false
    end

    it "revokes a permission from a user" do
      authz = Authz::Manager.new(user)
      authz.revoke(:send, user_badge)

      expect(user.permissions.count).to eql(0)
      expect(authz.can?(:send, user_badge)).to be_false
    end
  end
end


