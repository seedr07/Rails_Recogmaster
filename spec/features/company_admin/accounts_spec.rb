require 'spec_helper'

describe "Companies Accounts", js: true do
  describe 'Resending invitations' do

    let(:company_admin) { FactoryGirl.create(:company_admin, first_name: "Company", last_name: "Admin") }
    let(:company) { company_admin.company }

    before do
      login_as(company_admin)
      setup_spec if respond_to?(:setup_spec)
      visit company_path(network: company_admin.network)
      click_on "Accounts"
    end

    context "when editing another users profile" do
      let(:second_user) { FactoryGirl.create(:active_user,email: "#{FactoryGirl.generate(:email_prefix)}@#{company.domain}" )}
      let(:setup_spec) { second_user }

      it "should allow to open user profile to edit as admin" do
        page.find("#user_row_#{second_user.id} > td:nth-child(10) > .button.button-chromeless:nth-of-type(1)").click
        page.find(".button-no-chrome:nth-of-type(1)").click
        expect(page).to have_content("Successfully updated profile.")
        expect(page.find("#user_first_name").value).to eq(second_user.first_name)
        within(".profile") do
          expect(page).to have_content(company_admin.full_name)
        end
      end
    end

    describe "showing accounts tab" do
      it "shows accounts page and users table" do
        expect(page).to have_content "Accounts"
        expect(page).to have_css "table#user-set"
        company.users.each do |user|
          expect(page).to have_css "tr#user_row_#{user.id}"
        end
      end
    end

    # here we have a secondary user(not the company admin) invite someone
    # then we resend invitation by the company admin and make sure the inviter remains the company admin
    describe "resending invitations" do
      let(:invited_user_email) { "#{FactoryGirl.generate(:email_prefix)}@#{company.domain}" }
      let(:first_inviter) { FactoryGirl.create(:active_user, email: "#{FactoryGirl.generate(:email_prefix)}@#{company.domain}", first_name: "First", last_name: "Inviter") }
      let(:setup_spec) { first_inviter.invite!(invited_user_email) }
      let(:invited_user) { User.find_by(email: invited_user_email) }
      let(:resend_invite_selector) { "tr#user_row_#{invited_user.id} a.resend_invitation_email_link" } 

      it "should resend invitation via current user" do
        orig_email_count = ActionMailer::Base.deliveries.length
        expect(page).to have_css "tr#user_row_#{invited_user.id}"
        expect(page).to have_css resend_invite_selector

        page.find(resend_invite_selector).click
        wait_until_ajax_completes
        expect(ActionMailer::Base.deliveries.length).to eq(orig_email_count + 1)

        last_email = ActionMailer::Base.deliveries.last
        expect(last_email.subject).to match(/#{company_admin.full_name} invites you to Recognize/)
      end
    end
  end
end
