require 'spec_helper'

describe "Company Roles Index", js: true do
  let(:user) { FactoryGirl.create(:company_admin) }
  let(:company_role) { FactoryGirl.create(:company_role, company_id: user.company_id) }

  before do
    login_as(user)
  end

  context "Creating a role" do
   before { visit company_admin_roles_path(network: user.network) }

   it "creates role" do
    page.find('#company_role_name').set('Professor')
    click_on "Create Role"
    within "#role-set" do 
      expect(page).to have_content "Professor"
    end

    visit company_admin_roles_path(network: user.network)

    within "#role-set" do 
      expect(page).to have_content "Professor"
    end

   end

  end

  context "Editing a role" do 
    before do
      company_role
      visit company_admin_roles_path(network: user.network)
    end

    it "shows edit form" do 
      click_on "Edit"
      within "#company-role-#{company_role.id}" do 
        expect(page).to have_css "form#edit_company_role_1"
        expect(page).to have_button "Update"
        expect(page).to have_link "Cancel"
      end
    end

    context "when updating" do
      let(:new_role_name) { "Executive" }
      before { click_on "Edit" }

      it "should update" do 
        within "#company-role-#{company_role.id}" do 
          fill_in "company_role[name]", with: new_role_name
          click_on "Update"
          expect(page).to_not have_css "form#edit_company_role_1"
          expect(page).to have_content new_role_name
        end
      end      
    end

    context "when canceling" do
      let(:new_role_name) { "Executive" }
      before { click_on "Edit" }

      it "should return to showing" do
        within "#company-role-#{company_role.id}" do 
          fill_in "company_role[name]", with: new_role_name
          click_on "Cancel"
          expect(page).to_not have_css "form#edit_company_role_1"
          expect(page).to_not have_content new_role_name
          expect(page).to have_content company_role.name
        end
      end
    end

    context "when deleting" do
      it "should delete" do 
        click_on "Delete" 
        expect(page).to_not have_content company_role.name
      end
    end
  end
end