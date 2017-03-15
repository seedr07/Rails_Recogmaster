require 'spec_helper'

describe "Companies Admin", js: true do
  describe 'Rewards' do

    let(:company_admin) { FactoryGirl.create(:company_admin) }
    let(:company) { company_admin.company }

    before do
      login_as(company_admin)
      visit company_path(network: company_admin.network)

      go_to_admin_rewards

      wait_until_page_has_selector("#rewards-main-area")
      wait_until_ajax_completes
    end


    describe "Create tab" do
      it "shows rewards" do
        within("#rewards") do
          expect(page).to have_content "Rewards"
        end
      end

      it "creates a new reward form when clicked add reward" do
        within("#rewards") do
          expect(page).to have_content "Add Reward"

          page.should have_css(".reward-card", :count=>0)
          click_link("Add Reward")
          page.should have_css(".reward-card", :count=>1)
          click_link("Add Reward")
          page.should have_css(".reward-card", :count=>2)
        end
      end

      it "creates a reward" do
        click_link("Add Reward")

        page.should have_css(".reward-card", :count=>1)
        visit company_path(network: company_admin.network)

        go_to_admin_rewards

        wait_until_page_has_selector("#rewards-main-area")

        page.should have_css(".reward-card", :count=>0)

        click_link("Add Reward")

        wait_until_ajax_completes
        page.should have_css(".reward-card", :count=>1)

        page.attach_file("reward_image", File.join(Rails.root, "app/assets/images/pages/home-engagement/bg.png"))

        page.execute_script("$('.reward-card .title-input').val('Burning Man tickets for your entire team')")
        page.execute_script("$('.reward-card .description-input').val('Yo got that right')")
        page.execute_script("$('.reward-card .points-input').val('100')")
        page.execute_script(%Q($('.reward-manager-select').select2('open')))
        page.execute_script(%Q($(".select2-search__field").val('#{company_admin.first_name}')))
        page.execute_script(%Q($(".select2-search__field").trigger('keyup')))
        wait_until_page_has_selector('.select2-results__option--highlighted')
        page.execute_script(%Q($('.select2-results__option--highlighted').trigger('mouseup')))
        page.execute_script("$('.reward-card .button').click()")
        wait_until_ajax_completes(120)

        visit company_path(network: company_admin.network)

        go_to_admin_rewards

        wait_until_page_has_selector("#rewards-main-area")

        expect(page.evaluate_script("$('.reward-card .reward-image').attr('src').length")).to be > 1

        expect(page).to have_selector("input[value='Burning Man tickets for your entire team']")
        expect(page).to have_field('reward_description', with: 'Yo got that right')
        expect(page).to have_selector("input[value='100']")

        page.should have_css(".reward-card", :count=>1)

        click_link("header-rewards")

        expect(page).to have_content("Burning Man tickets for your entire team")
        expect(page).to have_content("Yo got that right")
        expect(page).to have_content("100")
        expect(page.evaluate_script("$('.reward-header').attr('style').length")).to be > 1
        expect(page).to have_content("Redeemable for 100 points")
        company_admin.redeemable_points = 1000
        company_admin.save!
        click_link("header-rewards")
        
        click_on("REDEEM FOR 100 POINTS")
        wait_until_page_has_selector(".redeemed")
        expect(page).to have_content("Redeemed")
        expect(page).to have_selector(".redeemed")
      end

      it "deletes a reward" do
        page.should have_css(".reward-card", :count=>0)

        r = FactoryGirl.create(:reward, company_id: company.id, points: 50)

        go_to_admin_rewards

        wait_until_page_has_selector("#rewards-main-area")

        page.should have_css(".reward-card", :count=>1)

        click_on("Delete")
        sleep(0.5)
        click_on("Yes, remove it!")

        wait_until_ajax_completes

        sleep(0.5)

        page.should have_css(".reward-card", :count=>0)

        visit company_path(network: company_admin.network)

        go_to_admin_rewards

        wait_until_page_has_selector("#rewards-main-area")

        page.should have_css(".reward-card", :count=>0)

        expect(r.reload.enabled).to be_false
      end

    end


    describe "List tab" do
      it "shows accounts page and users table" do
        expect(page).to have_content "REDEEMED"
        click_link "Redeemed"

        expect(page).to have_css "#rewards-list-area .table"
        expect(page).to_not have_content "Add Reward"
        expect(page).to have_content "Reward Description"

        click_link "Create"

        expect(page).to_not have_content "Reward Description"
        expect(page).to have_content "Add Reward"
      end
    end
  end
end

def go_to_admin_rewards
  visit company_path(network: company_admin.network)

  within(".admin-nav") do
    click_on "Rewards"
  end
end