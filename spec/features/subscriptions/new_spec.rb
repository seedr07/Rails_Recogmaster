require 'spec_helper'

describe "Subscriptions", js: true, feature: true do
  include ActionView::Helpers::NumberHelper
  include DateTimeHelper
  
  describe "I can contact the Recognize team if I want to sign up" do
    before(:each) do
      @user = login_as(:active_user)
      visit upgrade_path(network: @user.network)
    end

    it "Has title text" do
      expect(page).to have_content("Upgrade Recognize")
    end

    it "should show testimonial for social proof" do
      expect(page).to have_content("We can reinforce our core values and behaviors, and even use custom badges to set goals for people.")
    end

    it "should show a link to the contact page" do
      click_on "Notify us to get started"
      wait_until_ajax_completes
      expect(page).to have_content("Thanks for your interest.")
      expect(page).to have_content("Please contact us")
    end
  end

  describe 'Subscription checkout' do
    let(:company) { subscription.company }
    let(:company_admin) { company.users.first }
    let(:subscription) { FactoryGirl.create(:subscription_with_line_items) }

    before do
      Plan::Syncer.sync!(subscription)
      @user = login_as(company_admin)
      @title = "Banana Inc Integrates with Recognize"
      visit subscription_path(subscription, network: company.domain)
    end

    it "shows form and line items" do
      expect(page.current_path).to eq(subscription_path(subscription, network: company.domain))
      expect(page).to have_content "Payment Agreement"
      expect(page).to have_content "Recurring cost"
      subscription.line_items.each do |item|
        expect(page).to have_content number_to_currency(item.amount, precision: 2)
        expect(page).to have_content item.description
      end

      expect(page).to have_content number_to_currency(subscription.total_with_unbilled_line_items, precision: 2)
      expect(subscription.total_with_unbilled_line_items).to_not eq(subscription.amount) # sanity check
    end

    it "does not show contract information" do
      expect(page).to_not have_content("Signature")
      expect(page).to_not have_content("Sign signature here")
      expect(page).to_not have_content("Sign date")
      expect(page).to_not have_selector("#subscription_contract_signature")
      expect(page).to_not have_selector("#subscription_sign_date")
    end

    context "when a contract is included" do
      before do
        @title = "Banana Inc Integrates with Recognize"
        @body = "<h2>Features</h2><p>Cool option</p>"
        subscription.contract_title = @title
        subscription.contract_body = @body
        subscription.save!(validate: false)
        visit page.current_path
      end

      it "should show contract title and body" do
        expect(page).to have_content(@title)
        expect(page.body).to include(@body)
      end

      it "should show signature and sign date" do
        expect(page).to have_content("Sign signature here")
        expect(page).to have_content("Sign date")
        expect(page).to have_selector("#subscription_contract_signature")
        expect(page).to have_selector("#subscription_sign_date")
        expect(page).to have_field("subscription_sign_date", with: localize_datetime(Time.now, :friendly))
      end

      it "should be able to edit signature field and date field always read only" do
        expect(page).to_not have_selector("#subscription_contract_signature[readonly]")
        expect(page).to have_selector("#subscription_sign_date[readonly]")
      end

      context "Signature is signed" do
        before do
          fill_in "subscription_contract_signature", with: "Alex Grande"
          fill_in "subscription_sign_date", with: "July 11, 2015"
          fill_in_cc
        end

        it "should show signature and saved date" do
          expect(page).to have_field("subscription_contract_signature", with: "Alex Grande")
          expect(page).to have_field("subscription_sign_date", with: localize_datetime(Time.now, :friendly))
          expect(page).to have_content("Sign signature here")
          expect(page).to have_content("Sign date")
        end

        it "should be read only contract inputs" do
          expect(page).to have_selector("#subscription_contract_signature[readonly]")
          expect(page).to have_selector("#subscription_sign_date[readonly]")
        end
      end
    end

    context "when checking out" do
      before do
        @total_billed = subscription.total_with_unbilled_line_items
        fill_in_cc
      end

      it "should purchase successfully" do
        expect(subscription.archived?).to be_false
        expect(page).to have_content "Subscription was successfully purchased"
        expect(subscription.reload.email).to be_present
        expect(page).to have_content Time.now.strftime("%Y-%m-%d")
        expect(page).to have_content 1.month.from_now.strftime("%Y-%m-%d")
        expect(page).to have_content "Next Invoice #{1.month.from_now.strftime("%Y-%m-%d")} - $#{number_with_precision(subscription.amount, precision: 2)}"
        expect(page).to have_content "Previous Invoice #{Time.now.strftime("%Y-%m-%d")} - $#{number_with_precision(@total_billed, precision: 2)}"
      end

      context "when updating card" do
        before do
          fill_in "card-number", with: "4242424242424242"
          fill_in "card-cvc", with: "123"
          fill_in "card-expiry-month", with: "12"
          fill_in "card-expiry-year", with: 1.year.from_now.year
          click_on "Update"
        end

        it "should update successfully" do
          expect(page).to have_content "Subscription was successfully updated"
          expect(subscription.reload.email).to be_present
          expect(page).to have_content "Next Invoice"
          expect(page).to have_content "Previous Invoice"
          expect(page).to have_content Time.now.strftime("%Y-%m-%d")
          expect(page).to have_content 1.month.from_now.strftime("%Y-%m-%d")
        end
      end
    end
  end

end

def fill_in_cc
  fill_in "card-number", with: "4242424242424242"
  fill_in "card-cvc", with: "123"
  fill_in "card-expiry-month", with: "12"
  fill_in "card-expiry-year", with: 1.year.from_now.year
  click_on "Purchase"
end