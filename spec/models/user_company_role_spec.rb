require 'spec_helper'

describe UserCompanyRole do
  let!(:company) { Company.create!(name: "Corp-X", domain: "domination.com") }
  let!(:role) { company.company_roles.create!(name: "Executive") }
  let!(:user) { User.create!(first_name: "Joe", last_name: "Smith", email: "joe@domination.com") }

  it "must be uniq per user" do
    user.company_roles.add(role)
    user.company_roles.add(role)

    expect(user.company_roles.count).to eql(1)
  end
end
