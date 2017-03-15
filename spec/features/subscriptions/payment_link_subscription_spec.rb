require 'spec_helper'

describe "Subscriptions", js: true, feature: true do
  let(:company) { FactoryGirl.create(:company_with_users) }
  let(:user) { company.users.first }
  let(:subscription) { Subscription::Creator.create(company, user, subscription_params)}
  let(:subscription_params) {{
    billing_start_date: Time.now.strftime("%m/%d/%Y"), 
    contract_title: "ACME Recognize subscription",
    contract_signature: "Sigggy",
    charge_interval: "Monthly",
    sign_date: Time.now.to_date,
    amount: 500
    }}

  before do
    subscription
    login_as user
  end

  context "when viewing welcome page and clicking purchase" do

    it "should redirect to subscription show page" do
      visit welcome_path(network: company.domain)
      click_on "Purchase"
      wait_until_ajax_completes
      wait_until_page_is_redirected_from upgrade_path(network: company.domain)
      expect(page.current_path).to eq(subscription_path(subscription, network: company.domain))
    end
  end

  context "when viewing stream page and clicking purchase" do
    it "should redirect to subscription show page" do
      visit recognitions_path(network: company.domain)
      click_on "Purchase"
      expect(page.current_path).to eq(subscription_path(subscription, network: company.domain))
    end
  end
end