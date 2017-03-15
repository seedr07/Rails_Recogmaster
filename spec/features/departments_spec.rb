require 'spec_helper'

describe "Departments", js: true do
  before(:each) { Capybara.javascript_driver = :selenium_chrome}
  after(:each) { Capybara.javascript_driver = :webkit}

  include RecognitionsHelper

  let(:admin) { FactoryGirl.create(:director) }
  let(:admin_coworker) { FactoryGirl.create(:active_user, email: "#{FactoryGirl.generate(:count)}@#{admin.network}")}
  let(:parent_company) { admin.company }
  let!(:child_company) { admin.company.make_child_company!("ChildCo-#{FactoryGirl.generate(:count)}") }
  let(:child_company_admin) { FactoryGirl.create(:active_user, email: "#{FactoryGirl.generate(:count)}@#{admin.network}")}

  def select_dept(company)
    page.execute_script(%Q($("#dept-select").val("#{company.domain}").trigger("select2:select")))
  end

  before do
    login_as admin
  end

  describe 'Basic company admin' do

    before do
      path = company_path(admin.network)
      visit path
    end

    context 'when not director' do
      let(:admin) { FactoryGirl.create(:company_admin) }

      it "should not show departments links" do
        expect(page.current_path).to eq(company_path(admin.network))
        expect(page).to have_content "Company Dashboard"
        expect(page).to_not have_selector "#dept-select"
        expect(page).to_not have_content child_company.name
      end
    end

    context 'when director' do

      before do
        visit company_path(admin.network)
        wait_until_ajax_completes
      end

      it "should show departments links" do

        expect(page.current_path).to eq(company_path(admin.network))
        expect(page).to have_content "Company Dashboard"
        expect(page).to have_selector "#dept-select"
        page.execute_script(%Q($("#dept-select").select2("open")))
        expect(page).to have_content child_company.name
      end      

      context "when choosing different department" do
        before do
          select_dept(child_company)
        end

        it 'should be on the chosen departments page' do
          uri = URI.parse(current_url)
          expect("#{uri.path}?#{uri.query}").to eq(company_path(admin.network, dept: child_company.domain))
        end

      end
    end    
  end

  describe 'Company admin tabs' do
    before do
      child_company_admin.move_company_to!(child_company)
      @parent_company_recognition = recognize!(admin, admin_coworker)      
      @child_company_recognition = recognize!(admin_coworker, child_company_admin)

      if defined?(before_visit)
        before_visit
      end

      visit company_path(network: admin.network)   
      wait_until_ajax_completes
    end    

    describe 'Dashboard' do
      shared_examples_for "company dashboard" do 
        it 'should show data' do
          Array(admin_users).each do |user|
            selector = %Q(.admin-avatars img[title='#{user.full_name}'])
            expect(page).to have_selector(selector)
          end
          # All in one spec test for faster performance(otherwise all before(:each) blocks are repeated)

          base_selector = ".flipboard-wrapper .flipboard.today"
          expect(page).to have_selector(base_selector+".users .number", text: user_count)
          expect(page).to have_selector(base_selector+".recognitions .number", text: recognition_count)
        end
      end

      context "directors own dept" do 
        let(:user_count) { 2 }
        let(:recognition_count) { 2 }
        let(:admin_users) { [admin] }

        it_behaves_like "company dashboard"
   
      end

      context "different dept" do      
        let(:user_count) { 1 }
        let(:recognition_count) { 1 }
        let(:admin_users) { [] }

        before do
          select_dept(child_company)
        end

        it_behaves_like "company dashboard"
      end
    end

    describe 'Custom Badges' do
      let(:custom_badge) { company.company_badges.first }

      let(:before_visit) do 
        company.enable_custom_badges!        
        custom_badge.update_column(:short_name, "Custom Badge for #{company.domain}")
      end

      shared_examples_for "custom badge dashboard" do 
        it "should show, create, and update proper badges" do
          badge_name_input_selector = "#badge-#{custom_badge.id} input.badge-name"

          # SHOW 
          expect(page).to have_link "Upload new badge"
          expect(page).to have_content "Active Badges"
          expect(page).to have_content "Disabled Badges"
          # expect(page).to have_field "company[badges][#{custom_badge.id}][short_name]", with: custom_badge.short_name
          expect(page.find(badge_name_input_selector)['value']).to eq(custom_badge.short_name)
          # expect(page.find("#custom_badges form")['action']).to eq()

          # UPDATE WITH ERRORS
          # FIXME: implement this...

          # UPDATE
          new_badge_name = "Updated badge name: #{company.domain}"
          # fill_in badge_name_input_selector, with: new_badge_name
          page.find(badge_name_input_selector).set(new_badge_name)
          click_on "Update badges"
          wait_until(30) do
            page.has_content?("Successfully updated badges")
          end
          wait_until_selector_has_class("#custom_badges", "active")
          expect(company.reload.company_badges.find(custom_badge.id).short_name).to eq(new_badge_name)
          expect(page.find(badge_name_input_selector)['value']).to eq(new_badge_name)

          # CREATE WITH ERRORS
          # page.find("form#custom-badges .drawer-trigger").click
          # click_on "+ Upload new badge"
          expect(page).to have_button("Create badge", visible: false)
          click_on "+ Upload new badge"
          wait_until_page_has_selector("form.new_badge")
          expect(page).to have_button "Create badge"
          click_on "Create badge"
          wait_until_ajax_completes
          expect(page).to have_content "Name must be selected"

          # CREATE
          new_badge_name = "New badge for #{company.domain}"
          description = "la la la"

          within("#view-drawer-wrapper") do
            # need to use javascript to set the name for some reason
            # it was intermittently not getting set in the form for some reason
            # page.find("#badge_short_name").set(new_badge_name)
            page.execute_script(%Q($('#view-drawer-wrapper #badge_short_name').val('#{new_badge_name}')))
            page.execute_script(%Q($('#view-drawer-wrapper #badge_description').val('#{description}')))
            # page.find("#badge_description").set(description)
            page.attach_file("Image", File.join(Rails.root, "app/assets/images/badges/150/choose.png"))
          end
          
          click_on "Create badge"
          wait_until_ajax_completes(30)

          element = "#active-badges-wrapper .widget-box:first-child"
          element_html = page.evaluate_script( %Q($('#{element}').html()) )

          expect(page.find(element).find('input.badge-name').value).to eq(new_badge_name)
          expect(page.find(element).find('.badge-description').value).to eq(description)
          # expect(element_html).to match(new_badge_name)
          # expect(element_html).to match(description)
          expect(element_html).to match("choose.png")
        end
      end

      before do
        click_on "Custom Badges"
        wait_until_ajax_completes
      end

      context "directors own dept" do
        let(:company) { parent_company }
        it_behaves_like "custom badge dashboard"     
      end

      context "different dept" do
        let(:company) { child_company }

        before do
          select_dept(child_company)
        end

        it_behaves_like "custom badge dashboard"
      end
    end

    describe 'Accounts' do
      shared_examples_for "accounts tab" do
        it "should have their users only for its sub company" do
          click_on "Accounts"
          wait_until_ajax_completes
          expect(page.evaluate_script(%Q($("#user-set tr").length))).to eq(user_count)
        end
      end

      context "directors own dept" do
        let(:company) { parent_company }
        let(:user_count) { 3 }
        it_behaves_like "accounts tab"
      end

      context "different dept" do
        let(:user_count) { 2 }
        let(:company) { child_company }

        before do
          select_dept(child_company)
        end

        it_behaves_like "accounts tab"
      end
    end


    describe 'Settings' do
      let(:default_on_settings) { 9 }
      let(:default_off_settings) { 11 }

      shared_examples_for "settings tab" do
        it "Saves settings for its company" do
          # main company
          wait_until_ajax_completes
          # debugger unless page.evaluate_script(%Q($("#settings input[type='checkbox']:checked").length)) == default_off_settings
          expect(page.evaluate_script(%Q($("#settings input[type='checkbox']:checked").length))).to eq(default_off_settings)
          expect(page.find("#settings #reset-interval").find("option[selected]").text).to eq("Yearly")          

          select_dept(other_company)
          wait_until_ajax_completes

          # other company
          expect(page.evaluate_script(%Q($("#settings input[type='checkbox']:checked").length))).to eq(default_on_settings)
          expect(page.find("#settings #reset-interval").find("option[selected]").text).to eq("Monthly")          
        end
      end

      before do
        click_on "Settings"
      end

      context "directors own dept" do
        let(:company) { parent_company }
        let(:other_company) { child_company }
  
        before do
          page.execute_script(%Q($(".on-off").click()))
          select "Yearly", from: "reset-interval"
          wait_until_ajax_completes
          page.execute_script("window.location.reload()")
        end

        it_behaves_like "settings tab"
      end


      context "different dept" do
        let(:company) { child_company }
        let(:other_company) { parent_company }

        before do
          select_dept(child_company)
          page.execute_script(%Q($(".on-off").click()))
          select "Yearly", from: "reset-interval"
          wait_until_ajax_completes
          page.execute_script("window.location.reload()")
          wait_until_ajax_completes
        end

        it_behaves_like "settings tab"
      end
    end
  end
end