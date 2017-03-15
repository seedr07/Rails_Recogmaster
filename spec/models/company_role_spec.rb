require "spec_helper"
require "pp"

describe CompanyRole do
  let!(:google) { Company.create!(name: "Google", domain: "google.com") }
  let!(:john) { User.create!(first_name: "John", last_name: "Jupiter", email: "john@google.com") }
  let!(:bill) { User.create!(first_name: "Bill", last_name: "Buckingham", email: "bill@google.com") }
  let!(:director_role) { google.company_roles.create!(name: "Director") }
  let!(:executive_role) { google.company_roles.create!(name: "Executive") }
  let!(:workaholic) { google.badges.create!(short_name: "workaholic") }
  let!(:send_badge_permission) { Permission.create!(target_class: "Badge", target_action: "send", target_id: workaholic.id) }

  context "permissions" do
    it "can be assigned a permission" do
      executive_role.grant(send_badge_permission)

      expect(executive_role.permissions.length).to eql(1)
      expect(executive_role.permissions.first).to eql(send_badge_permission)
    end
  end

  context "when deleted" do
    it "removes associated user_company_role records" do
      john.company_roles.add(director_role)
      director_role.destroy

      expect(john.company_roles.find_by(name: "Director")).to be_nil
    end

    it "removes associated company_role_permission records" do
      director_role.grant(send_badge_permission)
      expect(send_badge_permission.company_role_permissions.count).to eql(1)

      director_role.destroy
      expect(send_badge_permission.company_role_permissions.count).to eql(0)
    end
  end
end


