require "spec_helper"

describe "Nominations", feature: true, js: true do
  include RecognitionsHelper
  include NominationsHelper

  let(:user) { FactoryGirl.create(:active_user) }
  before { login_as(user) }

  context "recognition form" do
    context "when setting is turned off and there is a nomination badge" do 
      it "should have not link to nomination form" do
        user.company.update_attribute(:allow_nominations, false)
        user.company.company_badges.first.update_column(:is_nomination, true)

        expect(user.company.nominations_enabled?(user)).to be(false)

        visit new_recognition_path(network: user.network)
        expect(page).to_not have_css("div.recognition-type")
      end
    end

    context "when setting is turned on and there is no nomination badge" do
      it "should have not link to nomination form" do
        user.company.update_attribute(:allow_nominations, true)
        user.company.company_badges.update_all(is_nomination: false)

        expect(user.company.nominations_enabled?(user)).to be(false)

        visit new_recognition_path(network: user.network)
        expect(page).to_not have_css("div.recognition-type")
      end
    end

    context "when setting is turned on and there is a nomination badge" do
      it "should have link to nomination form" do
        user.company.update_attribute(:allow_nominations, true)
        user.company.company_badges.first.update_column(:is_nomination, true)

        expect(user.company.nominations_enabled?(user)).to be(true)

        visit new_recognition_path(network: user.network)
        expect(page).to have_css("div.recognition-type")
        within "div.recognition-type" do
          expect(page).to have_content "Recognize"
          expect(page).to have_content "Nominate"
        end
      end
    end
  end

  context "new nomination form" do
    let(:recipient) { FactoryGirl.create(:active_user, email: "#{FactoryGirl.generate(:email_prefix)}@#{user.network}")}
    before do
      user.company.update_attribute(:allow_nominations, true)
      user.company.company_badges.first.update_column(:is_nomination, true)
      visit new_nomination_path(network: user.network)
    end

    it "shows nomination form" do
      expect(page).to have_content ActionView::Base.full_sanitizer.sanitize(I18n.t("nomination_new.recipient_search_title_html"))
      expect(page).to have_button I18n.t("nomination_new.send_nomination")
    end

    context "submitting nomination form with all parameters" do
      before do
        Badge.update_all(sending_interval_id: Interval.daily.to_i)
        select_badge
        add_recipient(recipient)
      end

      it "should be on users nominations index page" do
        expect(Nomination.count).to eq(0)
        within "#recognition-submit-wrapper" do 
          click_on "Nominate"
        end
        wait_until_ajax_completes
        expect(Nomination.count).to eq(1)

        expect(page.current_path).to eq(nominations_path(network: user.network))
      end
    end

    context "submitting nomination form with no parameters" do
      it "should show error messages" do
        within "#recognition-submit-wrapper" do 
          click_on "Nominate"
        end
        wait_until_ajax_completes
        expect(Nomination.count).to eq(0)
        
        expect(page).to have_content "Badge must be selected" # i tried to figure out translation key, but its weird...
        expect(page).to have_content I18n.t('activerecord.errors.models.nomination.recipient_or_email')
      end
    end
  end
end
