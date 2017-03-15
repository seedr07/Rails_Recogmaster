require 'spec_helper'

describe "Recognitions", type: :feature, js: true do
  include RecognitionsHelper
  Capybara::Session.send(:include, RecognitionsHelper::Session)
  
  before(:each) do
    User._create_system_user! unless User.system_user and User.system_user.persisted?
    @user = login_as(:active_user)
    @domain = @user.company.domain
    @recipient = FactoryGirl.create(:active_user, email: "a#{FactoryGirl.generate(:count)}@#{@domain}")
  end

  describe "GET /recognitions" do
    describe "unpaid companies" do
      before do
        visit(recognitions_path(network: @user.network))
      end
    
      it "should show a company admin link" do    
        expect(page).to have_selector("#recognition-details .well .button", text: "View Company Admin")
      end
    
    end

    describe "paid companies" do
      before do
        @user.company.enable_admin_dashboard!
        visit(recognitions_path(network: @user.network))
      end

      it "should not show company admin link for paid companies" do
        expect(page).to_not have_selector("#recognition-details .well .button")
      end

    end


    describe "truncation" do
      context "message is long" do
        before do
          # create long message recog nition
          # Go to recognitions page
          @lorem = "Lorem ipsum dolor sit amet, consectetur adipisicing elit. Adipisci aliquid, amet atque cum cumque, dolores error expedita illo in iste laudantium libero minus, nihil non officiis quidem repellat sed sequi! error expedita illo in iste laudantium libero minus, nihil non officiis quidem repellat sed sequi!"
          @recognition = FactoryGirl.create(:recognition, sender: @user, recipients: [@recipient], message: @lorem)
          visit(recognitions_path(network: @user.network))
        end

        it "should be truncated" do
          expect(page).to have_css("#recognition-card-#{@recognition.id}")
          expect( page.find("#recognition-card-#{@recognition.id} .message").text.index( @lorem[0, 100] ) ).to eq(0)
          expect(page.find("#recognition-card-#{@recognition.id} .message").text.length).to be < @lorem.length
        end

        it "should have a read more link that navigates to recognition show page" do
          expect(page.find("#recognition-card-#{@recognition.id} .message")).to have_content("Read more")

          page.find("#recognition-card-#{@recognition.id} .message .read-more").click
          wait_until_page_is_redirected_from(recognitions_path(network: @user.network))
          expect(page.current_path).to eq(recognition_path(@recognition))
        end

      end

      context "message is short" do
        before do
          @message = "message"
          @recognition = FactoryGirl.create(:recognition, sender: @user, recipients: [@recipient], message: @message)
          visit(recognitions_path(network: @user.network))
        end

        it "should not have a read more link" do
          expect(page.find("#recognition-card-#{@recognition.id} .message")).to_not have_content("Read more")
        end

        it "should show full message" do
          expect(page.find("#recognition-card-#{@recognition.id} .message")).to have_content(@message)
        end
      end
    end

    describe "when logged in" do
      before do
        visit recognitions_path(network: @user.network)
      end
    
      it "loads the recognitions stream page" do
        page.current_path.should == recognitions_path(network: @user.network)
        page.should have_content "Stream"
      end

      it "should go to badge page from link" do
        wait_until_page_url_is(recognitions_path(network: @user.network))
        click_on("Badges")
        wait_until_page_url_is(company_badges_path(@user.network))
        expect(page.current_path).to eq(company_badges_path(@user.network))
      end
      
    end
  end

  describe "sending recognition when we have an email address to preset" do
    context "when opening a recognition new page with params email" do
      let(:recipient) { FactoryGirl.create(:active_user)}

      before do
        visit new_recognition_path(network: @user.network, recognition: {recipient_emails: [recipient.email]})
        wait_until_ajax_completes
      end

      it "should show user preselected" do
        expect(page).to have_content recipient.full_name
      end

    end
  end


  describe "when sending a new recognition" do
    before do
      visit new_recognition_path(network: @user.network, new_recognition_exp: "normal")
      wait_until_ajax_completes
    end

    it "should show new recognition page" do
      page.current_path.should == new_recognition_path(network: @user.network)
      page.should have_button "Recognize"
      page.has_selector?('li.badge-item', :count => Badge.count)
    end
    
    context "and form is not filled out properly for reason exp" do
      before do
        visit new_recognition_path(network: @user.network, new_recognition_exp: "reason")
        within("#recognition-submit-wrapper") { click_on "Recognize" }
        wait_until_ajax_completes
      end

      it "should show appropriate errors for missing fields" do

        ["Badge must be selected", 
         "No recipients have been added"].each do |err|
          page.should have_selector("div.error h5", text: err)
        end
        page.should_not have_content("Company can't be blank")
      end
    end

    context "and form is not filled out properly" do
      before do
        within("#recognition-submit-wrapper") { click_on "Recognize" }
        wait_until_ajax_completes
      end

      it "should show badges in correct order" do
        Badge.all[1].update_attribute(:points, 100)
        Badge.all[1].save!
        visit new_recognition_path(network: @user.network)
        click_link("badge-trigger")

        within "#badge-list li:first-child" do
          expect(page).to have_content("100pts")
        end

        Badge.all[1].update_attribute(:points, 0)
        Badge.all[1].save!
        visit new_recognition_path(network: @user.network)
        click_link("badge-trigger")

        within "#badge-list" do
          expect(page).to have_content("0pts")
        end

        within "#badge-list li:first-child" do
          expect(page).to_not have_content("Boss")
        end
      end

      it "should show points for badges if badge has points" do


      end

      it "should show appropriate errors for missing fields" do

        ["Badge must be selected", 
         "No recipients have been added"].each do |err|
          page.should have_selector("div.error h5", text: err)
        end
        page.should_not have_content("Company can't be blank")
      end

      context "and send is clicked again" do
        before do
          within("#recognition-submit-wrapper") { click_on "Recognize" }
          wait_until_ajax_completes
        end
        
        it "should still show only one set of error messages" do
          ["Badge must be selected", 
           "No recipients have been added"].each do |err|
             page.should have_selector("div.error h5", text: err)
          end
          page.should_not have_content("Company can't be blank")
        end

        context "and partially filling out form" do
          before do
            wait_until_ajax_completes

            page.find("#top .image-wrapper").click
            
            page.find("li.badge-item:first-child .button").click         
            sleep 0.33 # sigh....
            wait_until_ajax_completes

            within("#recognition-submit-wrapper") { click_on "Recognize" }
            wait_until_ajax_completes
          end
        
          it "should update error messages appropriately" do

            ["No recipients have been added"].each do |err|
               page.should have_selector("div.error h5", text: err)
            end
            page.should_not have_content("Company can't be blank")
            page.should_not have_content("Badge must be selected")  

          end
        end
        
        context "and recipient email is entered with double @ symbol" do
          before do

            add_recipient('brandnewuser@#{@domain}@#{@domain}')

            select_badge

            fill_in :recognition_message, with: "Great job man!"
            within("#recognition-submit-wrapper") { click_on "Recognize" }
            wait_until_ajax_completes

          end

          it "should show error messages on recipient email" do
            ["Email should look like an email address."].each do |err|
              page.should have_selector("div.error h5", text: err)
            end
            ["Company can't be blank", "Badge must be selected"].each do |err|
              page.should_not have_selector("div.error h5", text: err)
            end

          end

        end        

      end
      
    end
    
    context "and form is filled out properly" do
      before do
        
        add_recipient(@recipient.email, @recipient.full_name)

        select_badge

        fill_in :recognition_message, with: "Great job!"
      end
      
      it "should show no errors and show flash message" do
        @initial_count = Recognition.count
        
        within("#recognition-submit-wrapper") { click_on "Recognize" }
        wait_until_ajax_completes(20)

        assert_sent_recognition!
      end
    end
    
    context "and form is filled out properly with an email address instead of a user" do
      context "and the email is outside the current company's domain" do
        before do
          add_recipient("barackobama#{Time.now.to_f.to_s}@whitehouse.gov")
        
          select_badge

          fill_in :recognition_message, with: "Great job!"
        end
        
        it "should not show error message" do
          @initial_count = Recognition.count
        
          within("#recognition-submit-wrapper") { click_on "Recognize" }
          wait_until_ajax_completes

          Recognition.count.should == @initial_count + 1
          page.current_path.should_not == new_recognition_path(network: @user.network)

          assert_sent_recognition!
        

        end
      end
      
      context "and the email is within the current company's domain" do
        before do
          add_recipient("brandnewuser@#{@domain}")

          select_badge

          fill_in :recognition_message, with: "Great job!"
        end
        
        it "should successfully send recognition" do
          @initial_count = Recognition.count
        
          within("#recognition-submit-wrapper") { click_on "Recognize" }
          wait_until_ajax_completes
        
          assert_sent_recognition!

        end
      end

    end
  end
  
  describe "when checking the permissions of a user" do
    before do
      @domain = @user.company.domain
      @second_user = FactoryGirl.create(:active_user, email: "a#{FactoryGirl.generate(:count)}@#{@domain}")
      @third_user = FactoryGirl.create(:active_user, email: "a#{FactoryGirl.generate(:count)}@#{@domain}")
    end

    it "should not have links to edit or delete for a recognition that was neither sent or received by user" do
      @recognition = FactoryGirl.create(:recognition, sender: @user, recipients: [@second_user])
      login_as(@third_user)

      visit root_path
      page.should have_selector("#recognition-card-#{@recognition.id}")
      within "#recognition-card-#{@recognition.id}" do
        page.should_not have_selector(".options-trigger")
        page.should_not have_selector(".recognition-edit")
        page.should_not have_selector(".recognition-delete")
      end
    end
    
    it "should only have links to delete for a recognition that was received" do
      @recognition = FactoryGirl.create(:recognition, sender: @user, recipients: [@second_user])

      login_as(@second_user)
      visit root_path
      ensure_delete_button(@recognition)
      page.should_not have_selector(recognition_edit_btn_selector(@recognition))
    end
    
    context "when deleting a recognition" do
      before do
        @recognition = FactoryGirl.create(:recognition, sender: @second_user, recipients: [@user])
        visit root_path
        ensure_delete_button(@recognition)
        page.find(recognition_delete_btn_selector(@recognition)).click
        wait_until_ajax_completes
      end
      
      it "should delete the recognition from the database" do
        Recognition.where(id: @recognition.id).should be_empty
      end
      
      it "should not have recognition in the view anymore" do
        page.should_not have_selector(recognition_delete_btn_selector(@recognition))
      end
    end
  end
  
  context "when dealing with privacy and sharing" do
    before do
      visit logout_path
      @recipient = FactoryGirl.create(:active_user) # do external company
      @recognition = @user.recognize!(@recipient, Badge.user_badges.first, "You're awesome!")
      @coworker = FactoryGirl.create(:active_user, email: "123123adf@#{@recognition.sender.company.domain}")
    end

    context "when logged out and viewing public recognition" do
      before do
        visit recognition_path(@recognition)
      end

      it 'loads show recognition page' do
        page.should be_on_recognition_page(@recognition)
      end
    end

    context "when logged in as someone in a different company" do
      before do
        @stranger = FactoryGirl.create(:active_user)
        login_as(@stranger)
        visit recognition_path(@recognition)
      end
      
      it "recognition should be public by default and be accessible" do
        page.should be_on_recognition_page(@recognition)
      end

      it "should show recognition" do
        visit recognition_path(@recognition)
        page.should be_on_recognition_page(@recognition)
      end
        
      it "should be approvable" do
        page.should have_selector ".vote"
        page.should_not have_selector "#recognition-access-wrapper.access-enabled"          
      end

      context "and recognition is made private" do
        before do
          @recognition.update_attribute :is_public, false
          visit recognition_path(@recognition)
        end

        it "should not allow viewing of recognition page" do
          page.should have_content "Sorry. You do not have permission to access that page"
        end

      end
    end
    
    context "when logged out and trying to view a private recognition" do
      before do
        @recognition.update_attribute :is_public, false
        visit recognition_path(@recognition)        
      end
      
      it "should not allow viewing a recognition when logged out" do
        page.current_path.should == login_path
      end
      
      context "and then logging in" do
        before do
          login_as(@recognition.sender, "abcd")
          visit recognition_path(@recognition)        
        end

        it "should take you to the recognition page" do
          page.should be_on_recognition_page(@recognition)
        end
      end
    end
    
    context "when attempting to toggle privacy as a coworker" do
      before do
        login_as(@coworker)
        visit recognition_path(@recognition)
        page.find("#recognition-access-wrapper").click
        wait_until_ajax_completes
      end

      it "should not allow toggling to private" do
        page.should_not have_selector("#recognition-access-wrapper.private")
        @recognition.reload.is_public?.should be_true
      end
    end

    context "when toggling privacy to private" do
      before do
        login_as(@recognition.recipients[0])
        visit recognition_path(@recognition)
        page.find("#recognition-access-wrapper").click
        wait_until_ajax_completes
      end
      
      it "should have made recognition private" do        
        page.should have_selector("#recognition-access-wrapper.private")
        @recognition.reload.is_public?.should be_false
      end
      
      context "and viewing it while not logged in" do
        before do
          visit logout_path
        end
        
        it "should show login page" do
          visit recognition_path(@recognition)
          wait_until_page_is_redirected_from(recognition_path(@recognition))
          page.current_path.should == login_path
        end
        
      end
      
      context "and viewing it while logged in as a user in another unrelated company" do
        before do
          visit logout_path
          @stranger = FactoryGirl.create(:active_user)
          login_as(@stranger)
          visit recognition_path(@recognition)
        end

        it "should not allow viewing of recognition page" do
          page.should have_content "Sorry. You do not have permission to access that page"
        end      
      end
      
      context "and viewing it while logged in as a user in recipient company" do
        before do
          visit logout_path
          login_as(@recipient)
          visit recognition_path(@recognition)
        end    

        it "should be on recognition page" do
           page.should be_on_recognition_page(@recognition)
           page.should_not have_content "Sorry. You do not have permission to access that page"
           page.should have_selector "img.badge-image"
           page.should have_selector ".message"
        end
      end

      context "and making it public again" do
        before do
          page.find("#recognition-access-wrapper").click
          wait_until_ajax_completes
        end

        it "should have made recognition public" do
          page.should have_selector("#recognition-access-wrapper")
          page.should_not have_selector("#recognition-access-wrapper.private")
          @recognition.reload.is_public?.should be_true
        end
      end
    end
  end

  context "when dealing with new cross company recognitions" do
    before do
      @recipient_email = FactoryGirl.generate(:email)
      visit new_recognition_path(network: @user.network, new_recognition_exp: "normal")
      # select_recipient = %Q($('#recognition_recipient_email').val('#{@recipient_email}'))
      # page.execute_script(select_recipient)
      add_recipient("#{@recipient_email}")      

      select_badge

      fill_in :recognition_message, with: "Great job!"
      within("#recognition-submit-wrapper") { click_on "Recognize" }
      wait_until_ajax_completes
      wait_until_page_url_is(recognition_path(Recognition.unscoped.last))

      assert_sent_recognition!      
      @recognition = Recognition.unscoped.last
    end

    context "and accessing public recognition show page while logged out" do
      before do
        visit logout_path
        visit  recognition_path(@recognition)        
      end

      it "should be accessible by a logged out user" do
        page.current_path.should == recognition_path(@recognition)
      end

      it "should not verify recipient without invite code" do
        @recognition.recipients.each{|r| r.verified?.should be_false}
      end

      it "should verify recipient when visited with invite code" do
        visit recognition_path(@recognition, invite: @recognition.recipients[0].perishable_token)
        @recognition.reload.recipients{|r|r.reload.verified?.should be_true}
      end

    end

    context "and accessing private recognition show page while logged out" do
      before do
        visit logout_path
        @recognition.toggle_privacy!
      end

      it "should be accessible when visited by recipient with invite code" do
        visit recognition_path(@recognition, invite: @recipient.perishable_token)
        page.current_path.should == recognition_path(@recognition)
      end
    end
  end

  describe 'recognitions#show' do
    let(:other_recipient) { FactoryGirl.create(:user) }
    let(:recognition) {FactoryGirl.create(:recognition, sender: @user, recipients: [other_recipient])}

    it 'has nametags that point to profiles for each user' do
      visit recognition_path(recognition)
      expect(page).to have_selector(".avatar-wrapper a[href='#{user_path(recognition.sender, network: recognition.sender.network)}']")
      expect(page).to have_selector(".avatar-wrapper a[href='#{user_path(other_recipient, network: other_recipient.network)}']")
    end

    context 'deleting a recognition' do
      before do
        visit recognition_path(recognition)
      end

      context 'when clicking delete' do
        before do
          page.find('.recognition-delete.button.button-no-chrome.danger').click
          wait_until_page_is_redirected_from(recognition_path(recognition))
        end

        it 'goes to stream recognition page' do
          expect(page).to have_content("Add new")
          expect(page).to have_selector("#recognitions-index")
        end

      end
    end

    context 'editing a recognition' do
      let(:edit_recognition_link) { edit_recognition_path(recognition, network: recognition.sender.network) }

      before do
        visit recognition_path(recognition)
      end

      it 'has link to edit recognition' do
        expect(page).to have_link "Edit recognition"
      end

      context 'when clicking edit recognition' do
        before do
          click_on "Edit recognition"
          wait_until_page_is_redirected_from(recognition_path(recognition))
        end

        it 'goes to edit recognition page' do
          expect(page.current_path).to eq(edit_recognition_link)
          expect(page).to have_field "recognition_message"
          expect(page).to have_selector "input#recognition_badge_id", visible: false
          expect(page).to have_field "recognition_skills"
          expect(page).to_not have_field "recognition_recipients"
        end

      end

      context 'when changing recognition message and badge' do
        let(:new_message) { "Great job on the presentation"}
        # b.id != 1 to avoid thumbs up badge.
        let(:new_badge) { Badge.user_badges.noncompany.detect{|b| b.id != recognition.badge_id && b.id != 1 }}

        before do
          visit edit_recognition_link
          fill_in "recognition_message", with: new_message
          page.find("#badge-edit").click
          page.find(".badge-image-small[data-badge-id='#{new_badge.id}']").click
          sleep 0.5
          click_on "Update Recognition"
          wait_until_ajax_completes
        end

        it 'shows recognition page with new message' do
          expect(page.current_path).to eq(recognition_path(recognition))
          expect(page).to have_content(new_message)
          expect(page).to have_content(new_badge.short_name.split.map(&:capitalize).join(' '))
        end
      end
    end

  end

  describe 'recognizing a team' do
    let(:team) { FactoryGirl.create(:team_with_users, company: @user.company) }
    let(:badge) { Badge.user_badges.first }

    before do
      visit new_recognition_path(network: @user.network)
      add_recipient(team)
      add_recipient(team.users.last)
      select_badge
      fill_in :recognition_message, with: "Great job!"
    end

    it 'recognizes team successfully' do
      @initial_count = Recognition.count
      within("#recognition-submit-wrapper") { click_on "Recognize" }
      wait_until_ajax_completes(30)
      assert_sent_recognition!

      recognition = Recognition.first
      expect(recognition.recognition_recipients.length).to eq(team.users.length + 1)
    end

  end

  describe 'editing a team recognition' do
    let(:team) {  FactoryGirl.create(:team_with_users, company: @user.company) }
    let(:recognition) {FactoryGirl.create(:recognition, sender: @user, recipients: [team])}    
    let(:new_message) { "Great job on the presentation"}
    let(:new_badge) { Badge.user_badges.noncompany.detect{|b| b.id != recognition.badge_id && b.id != 1}}
    let(:edit_recognition_link) { edit_recognition_path(recognition, network: recognition.sender.network) }

    before do
      visit edit_recognition_link
      fill_in "recognition_message", with: new_message
      page.find("#badge-edit").click
      page.find(".badge-image-small[data-badge-id='#{new_badge.id}']").click
      sleep 0.5
      click_on "Update Recognition"
      wait_until_ajax_completes
    end    

    it 'shows recognition page with new message' do
      expect(page.current_path).to eq(recognition_path(recognition))
      expect(page).to have_content(new_message)
      expect(page).to have_content(new_badge.short_name.split.map(&:capitalize).join(' '))
    end      
  end
end
