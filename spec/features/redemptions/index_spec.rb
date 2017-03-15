require "spec_helper"

describe "Redemptions view for users to get rewards", js: true do

  let!(:user) { login_as(:active_user, "abcd", redeemable_points: 100) }
  let!(:company) { user.company }
  let!(:reward_in_range) { FactoryGirl.create(:reward, title: "In range thing", company_id: user.company_id, points: 50) }
  let!(:reward_out_range) { FactoryGirl.create(:reward, title: "Out range thing", company_id: user.company_id, points: 100000) }

  context "shows redemptions" do
    before do
      visit redemptions_path(network: company.domain)
    end

    it "shows redemptions in your point range and out of point range" do
      expect(page).to have_css("#reward-card-#{reward_in_range.id}.redeemable")
      expect(page).to have_css("#reward-card-#{reward_out_range.id}.unredeemable")

      expect(page).to have_content("Redeemable for 100000 points")
    end
  end

  context "not showing disabled redemptions" do
    before do
      reward_in_range.update_column(:enabled, false)
      visit redemptions_path(network: company.domain)
    end

    it "does not show the reward that id disabled" do
      expect(page).to_not have_css("#reward-card-#{reward_in_range.id}.redeemable")
    end
  end

  context "Redeeming a reward" do
    before do
      @original_email_count = ActionMailer::Base.deliveries.length
      visit redemptions_path(network: company.domain)
      within("#reward-card-#{reward_in_range.id}") do
        click_on "REDEEM FOR 50 POINTS"
        wait_until_ajax_completes
      end
    end

    it "should send an email" do
      expect(ActionMailer::Base.deliveries.length).to eq(@original_email_count + 2)
      user_email, admin_email = *ActionMailer::Base.deliveries.last(2)
      expect(admin_email.subject).to eq("User1 UserLastName1 has redeemed a reward!")
      expect(user_email.subject).to eq("You've redeemed points for a reward!")
    end

    it "should status for the reward when it is redeemed" do
      expect(page).to have_content("Redeemed")
    end

    it "updates the redeemable points for the user on the nav" do
      expect(page.evaluate_script(%Q($('.redeemable_points_total').html()))).to eq("-50")
    end

  end


end