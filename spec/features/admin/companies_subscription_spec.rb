require 'spec_helper'

describe "Companies::Subscription", js: true do
  let(:company) { FactoryGirl.create(:company_with_users) }
  let(:admin) { FactoryGirl.create(:admin)}

  before do
    login_as(admin)
  end

  describe '#create' do
    before do
      visit new_admin_company_subscription_path(company)
    end

    it 'should show contract fields' do
      expect(page).to have_selector("#subscription_contract_title")
      expect(page).to have_selector("#trumbowyg")
    end

    it 'should show new subscription form' do
      expect(page.current_path).to eq(new_admin_company_subscription_path(company))
      click_on "Next"
      expect(page).to have_content "Create Subscription"
    end

    context '#credit card' do
      it 'should validate amount' do
        click_on "Next"
        click_on 'Create Subscription'
        expect(page).to have_content "Amount can't be blank"
        expect(page).to_not have_content "Billing start date can't be blank"
      end
    end

    context '#check' do
      context 'when missing required attributes' do
        it 'should validate amount and billing start date' do
          click_on "Next"
          choose "Check"
          click_on 'Create Subscription'
          expect(page).to have_content "Amount can't be blank"
          expect(page).to have_content "Billing start date can't be blank"
        end
      end

      context 'when required attributes are present' do
        it 'should successfully submit form' do
          click_on "Next"
          choose "Check"
          fill_in "subscription_amount", with: 500
          fill_in "subscription_billing_start_date", with: Time.now.strftime("%m/%d/%Y")
          click_on 'Create Subscription'
          wait_until_ajax_completes(100)
          expect(page.current_path).to eq(admin_subscriptions_path)
          expect(page).to have_selector("#active-trigger.active")
          subscription = Subscription.last
          expect(page).to have_link('Edit', href: edit_admin_company_subscription_path(subscription.company, subscription))
        end
      end
    end
  end

  describe '#update' do
    let(:subscription) { FactoryGirl.create(:subscription) }

    before do
      Plan::Creator.create!(subscription)
      visit edit_admin_company_subscription_path(subscription.company, subscription)
    end

    it "should show form" do
      expect(page.current_path).to eq(edit_admin_company_subscription_path(subscription.company, subscription))
      click_on "Next to payment"
      expect(page).to have_content "Change Subscription"
    end


  end
end