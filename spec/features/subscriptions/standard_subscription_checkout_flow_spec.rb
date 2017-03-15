require 'spec_helper'

describe "Subscriptions", js: true, feature: true do
  let(:company) { FactoryGirl.create(:company_with_users) }
  let(:user) { company.users.first }

  before do
    login_as user
  end

  shared_examples_for "page that shows form to enter user count" do 
    it "should show user count form" do
      expect(page).to have_content "How many users do you have?"
      expect(page).to have_field "user_count"
    end
  end

  context "when viewing welcome page and clicking purchase" do
    before do
      visit welcome_path(network: company.domain)
      click_on "Purchase"
      wait_until_page_has_selector "#user-count.current"
    end

    it_behaves_like "page that shows form to enter user count"

  end

  context "when viewing stream page and clicking purchase" do
    before do
      visit recognitions_path(network: company.domain)
      click_on "Purchase"
      wait_until_page_has_selector "#user-count"
    end

    it_behaves_like "page that shows form to enter user count"

    it "is on special welcome page" do
      uri = URI.parse(current_url)
      full_path = "#{uri.path}?#{uri.query}"
      expect(full_path).to eq(welcome_path(network: company.domain, upgrade: true))
    end
  end

  context "when setting number of users" do
    let(:count) { 200 }
    let(:ppu) { 2 }
    let(:discount) { 0.1 }

    before do 
      visit welcome_path(network: company.domain, upgrade: true)
      fill_in "user_count", with: count
      click_on "Next"
      wait_until_page_has_selector "#user-count-low.current"
    end

    it "should show checkout form with correct number of users and price" do
      expect(page).to have_content "$#{count*ppu}.00/mo for #{count} users"
    end

    context "when checking out" do
      before do
        fill_in "card-number", with: "4242424242424242"
        fill_in "card-cvc", with: "123"
        fill_in "card-expiry-month", with: "12"
        fill_in "card-expiry-year", with: Time.now.year
        click_on "Purchase"
        wait_until_ajax_completes(20)
      end

      it "should show confirmation page" do
        uri = URI.parse(current_url)
        full_path = "#{uri.path}?#{uri.query}"
        expect(full_path).to eq(welcome_path(network: company.domain, upgrade: true))
        expect(page).to have_content "Congratulations!"
        expect(page).to have_content "Here is a list of next steps"

        subscription = Subscription.last
        expect(subscription.amount).to eq(count * 2)
      end
    end

    context "when clicking on yearly button" do
      it "should change price to yearly" do
        click_on "Yearly"
        expect(page).to have_css("#subscription-interval-yearly.button-pressed")
        expect(page).to_not have_css("#subscription-interval-monthly.button-pressed")
        expect(page).to have_content "$#{(count*ppu*12*(1-discount)).to_i}.00/yr for #{count} users"
        expect(page).to have_content "Includes #{(discount*100).to_i}% off"
      end
    end

    context "when checking out with yearly" do
      before do
        click_on "Yearly"
        fill_in "card-number", with: "4242424242424242"
        fill_in "card-cvc", with: "123"
        fill_in "card-expiry-month", with: "12"
        fill_in "card-expiry-year", with: Time.now.year
        click_on "Purchase"
        wait_until_ajax_completes(20)
      end

      it "should show confirmation page" do
        uri = URI.parse(current_url)
        full_path = "#{uri.path}?#{uri.query}"
        expect(full_path).to eq(welcome_path(network: company.domain, upgrade: true))
        expect(page).to have_content "Congratulations!"
        expect(page).to have_content "Here is a list of next steps"

        subscription = Subscription.last
        expect(subscription.amount).to eq(count * 12 * (1-discount) * ppu)

      end
    end

  end
end