require 'spec_helper'
require 'byebug'

describe "Companies", js: true do
  include Select2Helper

  describe "GET /company" do
    before do
      @user = login_as(:company_admin)
      @company = @user.company
      @company.company_roles.create!(name: "Executive")
      setup_spec if respond_to?(:setup_spec)
      visit company_path(network: @user.network)
    end

    it "get company dashboard" do
      page.current_path.should == company_path(network: @user.network)
      ["Dashboard", "Custom Badges", "Top Employees", "Accounts", "Settings"].each do |tab|
        expect(page).to have_link(tab)
      end
    end

    it "shows top employees" do
      click_on "Top Employees"
      expect(page).to_not have_content "Loading Top Employees..."
    end

    describe 'access to company admin' do
      context 'when unpaid' do
        let(:setup_spec) {
          @company.update_column(:allow_admin_dashboard, false)
        }

        it 'should show sample dashboard' do
          expect(page).to have_selector('#upgrade-link', visible: true)
          click_link("Dashboard")
          page.find("#upgrade-link").click()
          expect(page.current_path).to eq(welcome_path(network: @company.domain))
        end

        it "should show custom badge sign up message" do
          click_link "Custom Badges"
          expect(page).to have_content("Upload your own badges, edit existing ones, edit permissions, and more.")
        end

        it 'should show prompt when clicking on anything' do
          expect(page).to have_content("Top Employees")
          click_link("Top Employees")

          expect(page).to_not have_selector('.sweet-overlay')
          page.find("#rank .badge-dropdown-wrapper button").click()
          wait_until_page_has_selector('.sweet-overlay', 20)
          expect(page).to have_selector('.sweet-overlay', visible: true)

          page.find(".sweet-overlay").click()

          expect(page).to have_selector('.sweet-overlay', visible: false)

          expect(page).to have_content("Settings")
          click_link("Settings")

          expect(page).to have_selector('#settings', visible: true)

          page.execute_script('$("#settings > .marginBottom20:first .iOSCheckContainer .on-off").click()')
          expect(page).to have_selector('.sweet-overlay', visible: true)
        end
      end

      context 'when paid' do
        let(:setup_spec) {
          @user.company.enable_custom_badges!
        }

        it 'should show dashboard for non-recognition-sent companies and Custom Badges' do
          expect(page).to have_content("Get Started")
          expect(page).to have_content("Looks like your company hasn't sent any recognitions yet.")
          expect(page).to_not have_selector("#badge-line-graph-wrapper")

          click_link("Custom Badges")
          expect(page).to have_content("+ Upload new badge")
        end

        it 'should allow changing setting' do
          expect(page).to_not have_selector('.sweet-overlay')

          expect(page).to have_content("Settings")
          click_link("Settings")

          expect(page).to have_selector('#settings', visible: true)

          expect(page.evaluate_script('$("#settings > .marginBottom20:first .iOSCheckContainer .on-off").prop("checked")')).to be_false

          page.execute_script('$("#settings > .marginBottom20:first .iOSCheckContainer .on-off").click()')

          expect(page).to_not have_selector('.sweet-overlay')

          expect(page.evaluate_script('$("#settings > .marginBottom20:first .iOSCheckContainer .on-off").prop("checked")')).to be_true
        end
      end

      context 'when paid and sent a recognition already' do
        let(:setup_spec) {
          @user.company.enable_custom_badges!
          @domain = @user.company.domain
          @recipient = FactoryGirl.create(:active_user, email: "a#{FactoryGirl.generate(:count)}@#{@domain}")
          @recognition = FactoryGirl.create(:recognition, sender: @user, recipients: [@recipient], message: "Hi there!")
        }

        it 'should show dashboard with analtyics' do
          expect(page).to have_selector("h4", text: "Current Admins")
          expect(page).to have_selector("#badge-line-graph-wrapper", visible: true)
        end
      end
    end

    describe "#custom_badges" do
      let(:setup_spec) {
        @user.company.enable_custom_badges!
      }

      # let(:badge_permalink) { "/uploads/fake_badge_image.png" }

      before do
        # NOTE: stubbing doesn't seem to work with capybara
        #       if it ever works, it may speed up this test
        # Badge.any_instance.stub(:image=)
        # Badge.any_instance.stub(:local_file)
        # Badge.any_instance.stub(:permalink).and_return(badge_permalink)
        # Badge.any_instance.should_receive(:permalink).and_return(badge_permalink)
        click_on "Custom Badges"
      end

      it "shows custom badges" do
        expect(page).to have_link("Upload new badge")
        expect(page).to have_content("Active Badges")
        expect(page).to have_content("Disabled Badges")

        within("#active-badges-wrapper") do
          expect(page).to have_selector(".widget-box", count: 4)
          @user.company.badges.each do |badge|
            expect(page).to have_image(badge.permalink)
          end
        end

        within("#disabled-badges") do
          expect(page).to_not have_selector(".widget-box")
        end
      end

      context "when deleting a badge" do
        let(:deleted_badge) { @user.company.badges.first }

        it "should delete badge" do
          selector = "#badge-#{deleted_badge.id}"

          within("#custom_badges") do
            page.find(selector).click_on("Delete")
          end

          wait_until_ajax_completes
          page.should_not have_selector(selector)
          click_on "Update badges"
          expect(page).to have_content "Successfully updated badges"
          page.should_not have_selector(selector)
        end
      end

      context "when updating badges" do
        let(:disabled_badge) { @user.company.badges.first }
        let(:updated_badge) { @user.company.badges[2] }
        let(:new_name) { "Coool Badge" }
        let(:new_points) { 999 }

        before do
          # within("#badge-#{disabled_badge.id}") do
          #   uncheck "Enable"
          # end
          # uncheck "company_badges_#{disabled_badge.id}_enabled" 

          # neither of the above approaches are working, so fall back to js
          page.execute_script(%Q($("#company_badges_#{disabled_badge.id}_enabled").attr('checked', false)))

          within("#badge-#{updated_badge.id}") do
            fill_in("company[badges][#{updated_badge.id}][short_name]", with: new_name)
            fill_in("company[badges][#{updated_badge.id}][points]", with: new_points)
            # choose executive role for badge
            # page.execute_script(%Q($("#company_badges_#{updated_badge.id}_roles_ option").eq(1).attr('selected', true)))
            select2(@user.company.company_roles.first.id, from: "#company_badges_#{updated_badge.id}_roles_")
          end

          click_on "Update badges"
        end

        it "should make updates" do
          expect(page).to have_content "Successfully updated badges"

          click_on "Custom Badges"


          within("#active-badges-wrapper") do
            expect(page).to have_selector(".widget-box", count: (4 - 1))
            @user.company.badges.each do |badge|
              next if badge == disabled_badge
              expect(page).to have_image(badge.permalink)
            end
          end  

          within("#badge-#{updated_badge.id}") do
            expect(page).to have_field("company[badges][#{updated_badge.id}][short_name]", with: new_name)
            expect(page).to have_field("company[badges][#{updated_badge.id}][points]", with: new_points.to_s)
            expect(page.all("select#company_badges_#{updated_badge.id}_roles_ option[selected=selected]").length).to eql(1)
          end

          within("#disabled-badges") do
            expect(page).to have_selector(".widget-box", count: 1)
            expect(page).to have_image(disabled_badge.permalink)
          end  

        end
      end
    end

    describe '#recognitions' do
      before do
        click_on "Recognitions"
      end

      it 'should have appropriate columns' do
        table_selector = "#recognitions-table_wrapper"

        expect(page).to have_selector(table_selector)

        within(table_selector) do
          expect(page).to have_content("Points")
          expect(page).to have_content(@company.recognitions.first.earned_points)
        end
      end
    end

    describe 'changing kiosk mode url' do
      before do
        click_on "Settings"
      end

      it 'updates url with a valid code' do
        fill_in("company[kiosk_mode_key]", with: "abc123bvnuio")
        click_on "Update Kiosk Mode Url"
        wait_until_ajax_completes
        expect(page).to have_content "code=abc123bvnuio"
      end

      it 'displays error message on invalid url code' do
        fill_in("company[kiosk_mode_key]", with: "abc123bvnuio&")
        click_on "Update Kiosk Mode Url"
        wait_until_ajax_completes
        expect(page).to have_content "only contain letters and numbers"
      end

    end


    describe 'saving anniversary email recipients' do
      before do
        click_on "Settings"
      end

      context 'default' do
        it 'should not have anyone checked' do
          expect(page).to have_unchecked_field("roles_#{Role.company_admin.id}")
          expect(page).to have_unchecked_field("roles_#{Role.executive.id}")
          expect(page).to have_unchecked_field("all_teams_box")
        end
      end

      context 'selecting recipient' do

        it 'should save the checked recipient' do
          check "roles_#{Role.company_admin.id}"
          wait_until_ajax_completes
          visit company_path(network: @user.network)
          click_on "Settings"
          expect(page).to have_checked_field("roles_#{Role.company_admin.id}")
          expect(page).to have_unchecked_field("roles_#{Role.executive.id}")
          # expect(@company.reload.anniversary_notifieds[:role_ids]).to include(Role.company_admin.id)
        end

        context 'unselecting selected' do
          it 'should not save the unchecked recipient' do
            check "roles_#{Role.company_admin.id}"
            wait_until_ajax_completes
            uncheck "roles_#{Role.company_admin.id}"
            wait_until_ajax_completes
            visit company_path(network: @user.network)
            click_on "Settings"
            expect(page).to have_unchecked_field("roles_#{Role.company_admin.id}")
          end
        end

        context 'selecting teams manager' do
          it 'should save all teams' do
            check('all_teams_box')
            wait_until_ajax_completes
            visit company_path(network: @user.network)
            click_on "Settings"
            expect(page).to have_checked_field("all_teams_box")
          end
          it 'should not save any teams if unchecked' do
            check "all_teams_box"
            wait_until_ajax_completes
            uncheck "all_teams_box"
            wait_until_ajax_completes
            visit company_path(network: @user.network)
            click_on "Settings"
            expect(page).to have_unchecked_field("all_teams_box")
          end
        end

      end
    end
  end

  describe "Custom keyword for Kiosk mode" do
    before do
      @code = "a1234"
      @company = FactoryGirl.create(:company)
      @company.update_attribute(:kiosk_mode_key, @code)

    end

    it "shows kiosk when logged out with kiosk key" do
      visit stream_path(network: @company.domain, fullscreen: true, code: @code)
      expect(page).to have_content(@company.name)
    end

    it "does not show kiosk when logged out without kiosk key" do
      visit stream_path(network: @company.domain, fullscreen: true)
      expect(page).to_not have_content(@company.name)
    end
  end

end
