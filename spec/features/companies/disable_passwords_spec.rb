require 'spec_helper'


describe "Companies - disabling of passwords", js: true do
  def expect_to_show_idp_choices
    expect(page).to have_content "Sign in with Yammer"
  end

  let(:company) { FactoryGirl.create(:company_with_users) }
  let(:admin) { company.company_admins.first }

  before do
    setup_spec if respond_to?(:setup_spec)
  end

  describe "Editing user" do
    before do
      login_as(admin)
      visit edit_user_path(admin)
    end

    context "when password is not disabled" do
      it "should show password fields" do
        expect(page).to have_field "Original Password"
        expect(page).to have_field "Password"
      end

    end

    context "when password is disabled" do
      let(:setup_spec) { company.update_column(:disable_passwords, true) }

      it "should not show password fields" do
        expect(page).to_not have_field "Original Password"
        expect(page).to_not have_field "Password"
      end

      context "when saving" do
        before do
          page.find("input[name=commit].button-primary").click
          wait_until_ajax_completes
        end

        it "should save successfully" do
          expect(page).to have_content "Successfully updated profile"
        end
      end
    end
  end

  describe "Forgot Password" do
    before do
      visit new_password_reset_path
      fill_in "email", with: admin.email
      click_on "Reset my password"
    end

    context "when password is not disabled" do
      it "should send password reset email" do
        expect(page).to have_content "Instructions to reset your password have been emailed to you. Please check your email."
      end
    end

    context "when password is disabled" do
      let(:setup_spec) { company.update_column(:disable_passwords, true) }

      it "should redirect to idp page" do
        expect(page).to have_content "Passwords have been disabled as per your company policy."
        expect(page.current_path).to eq(identity_provider_path(network: company.domain))
        
        expect_to_show_idp_choices
      end
    end

  end

  describe "Signup" do
    let(:new_user_email) { "#{FactoryGirl.generate(:email_prefix)}@#{admin.network}" }
    let(:new_user) { User.find_by(email: new_user_email) } 

    before do
      visit sign_up_path
      within "#new_user" do
        fill_in "user_email", with: new_user_email
        click_on "Sign up"
      end
      wait_until_ajax_completes

      visit verify_signup_path(new_user.perishable_token)
    end

    context "when passwords are not disabled" do
      it "should only show form for first and last name" do
        expect(page).to have_css "input#user_first_name"
        expect(page).to have_css "input#user_last_name"
      end
    end

    context "when passwords are disabled" do
      let(:setup_spec) { company.update_column(:disable_passwords, true) }

      it "should only show options for identity provider" do
        expect(page).to_not have_css "input#user_first_name"
        expect(page).to_not have_css "input#user_last_name"
        expect(page.current_path).to eq(identity_provider_path(network: company.domain))
        expect_to_show_idp_choices      
      end
    end
  end

  describe "Signup via recognition" do
    let(:new_user_email) { "#{FactoryGirl.generate(:email_prefix)}@#{admin.network}" }
    let(:new_user) { User.find_by(email: new_user_email) } 

    before do
      @recognition = admin.recognize!(new_user_email, company.company_badges.first, "you've been rekanized")
      visit recognition_path(@recognition, invite: new_user.perishable_token)
    end

    context "when password is not disabled" do
      it "should have form to sign up" do
        expect(page).to have_field "user_first_name"
        expect(page).to have_field "user_last_name"
        expect(page).to have_field "user_password"
      end
    end

    context "when password is disabled" do
      let(:setup_spec) { company.update_column(:disable_passwords, true) }

      it "should show idp choices" do
        expect(page.current_path).to_not eq(identity_provider_path(network: company.domain))
        expect(page).to_not have_field "user_first_name"
        expect(page).to_not have_field "user_last_name"
        expect(page).to_not have_field "user_password"
        expect_to_show_idp_choices      
      end
    end
  end
end