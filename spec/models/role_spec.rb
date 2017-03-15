require 'spec_helper'

describe Role do

  context "when working with a role" do 

    it "should have 6 roles" do
      expect(Role.all.length).to eq(7)
    end

    it "should respond to all the role class methods" do
      expect(Role.system_user).to be_kind_of(Role)
      expect(Role.admin).to be_kind_of(Role)
      expect(Role.company_admin).to be_kind_of(Role)
      expect(Role.team_leader).to be_kind_of(Role)
      expect(Role.employee).to be_kind_of(Role)
      expect(Role.executive).to be_kind_of(Role)
    end
  end  
end
