require 'spec_helper'

describe "Users", js: true do

  context "when dealing with user profile" do
    before do
      @user = login_as(:active_user, "abcd", redeemable_points: 1000000)
    end
    ###############################################################
    #
    # When showing user profile
    #
    ###############################################################
    context "when showing an unscoped user profile" do
      before do
        @another_user = FactoryGirl.create(:active_user, email: "newuser123123123@#{@user.company.domain}")
        @another_user.recognize!(@user, Badge.user_badges.first, "You're awesome!")
        @another_user.recognize!(@user, Badge.user_badges.first, "So cool man!")
        @another_user.recognize!(@user, Badge.user_badges.find_by_id(31), "fast!")
        @user.recognize!(@another_user, Badge.user_badges.last, "Nice work")
        visit user_path(@user)
        wait_until_ajax_completes
      end
    
      it "should redirect and show logged in user profile scoped to logged in user" do
        page.current_path.should == user_path(@user)
      end

      it "should show the users recognitions" do
        expect(page).to have_content("You're awesome!")
        expect(page).to_not have_content("Nice work")
        click_on("Sent")
        expect(page).to_not have_content("You're awesome!")
        expect(page).to have_content("Nice work")
      end

      it "should show the users badge counts" do
        page.find("#badges-tab a").click
        expect(page).to have_content(Badge.user_badges.first.short_name)
        expect(page).to have_content(Badge.user_badges.find_by_id(31).short_name)
        within("#badges") do
          expect(page).to have_content("Speedy 1 #{Badge.user_badges.first.short_name} 2 Ambassador 1")
        end
      end

      it "should open recognition card menu for editing" do
        recognition = @user.reload.recognitions.last
        expect(page).to_not have_content("delete")
        page.execute_script(%Q($("#received #recognition-card-#{recognition.id} .options-trigger").trigger(R.touchEvent);))
        wait_until_ajax_completes
        within("#recognition-card-#{recognition.id}") do
          expect(page).to have_content("Delete")
          click_on("Delete")
          wait_until_ajax_completes
          expect(page).to_not have_selector("#received .recognition-card")
        end
      end


      context "rewards" do
        let!(:reward) { FactoryGirl.create(:reward, title: "In range thing", company_id: @user.company_id, points: 50) }

        context "enabled" do

          it "should show redemptions" do
            @user.company.update_attribute(:allow_rewards, true)
            @user.update_column(:redeemable_points, 100)

            redemption = FactoryGirl.create(:redemption, user_id: @user.id, reward_id: reward.id)

            reward = Reward.find(redemption.id)

            visit user_path(@user)

            expect(page).to have_content("REWARDS")

            within("#wrapper-outer") do
              click_link "Rewards"
            end

            expect(page).to have_content( reward.title )
            expect(page).to have_content( reward.description )
          end

          it "should say no redemptions if no redemptions exist but rewards" do
            @user.company.update_attribute(:allow_rewards, true)
            visit user_path(@user)

            expect(page).to have_content("REWARDS")

            within("#wrapper-outer") do
              click_link "Rewards"
            end

            expect(page).to have_content(I18n.t("rewards.no_redemptions"))
          end

        end


        it "should not show redemptions if rewards disabled" do
          @user.company.update_attribute(:allow_rewards, false)
          visit user_path(@user)
          expect(page).to_not have_content("REWARDS")
        end


      end


      # it "should show profile page" do
      #   page.current_path.should == user_path(@user)
      # end
    end

  end
  
  context "when a new user for a new company views stream page" do
    before do
      @user = FactoryGirl.create(:active_user)
      login_as(@user)
      visit root_path
    end

    it "should show first recognition" do
      assert_shows_first_user_badge(true)
    end

  end
  
  context "when a new user for an existing company views stream page and there haven't been any recognitions" do
    before do
      @first_user = FactoryGirl.create(:active_user)
      @user = FactoryGirl.create(:active_user, email: "newuser123123123@#{@first_user.company.domain}")
      login_as(@user)
      visit root_path
    end

    it "should not show first user welcome badge" do
      assert_shows_first_user_badge(false)
    end
    
    it "should show welcome box that can be closed" do
      assert_shows_close_link(true)
    end

    it "should have the correct content" do
      assert_shows_welcome_section(true)
    end
  end
  
  context "when a new user for an existing company views stream page and there have been recognitions" do
    before do
      @first_user = FactoryGirl.create(:active_user)
      @user = FactoryGirl.create(:active_user, email: "newuser123123123@#{@first_user.company.domain}")
      @user.recognize!(@first_user, Badge.user_badges.first, "You're awesome!")
      login_as(@user)
      visit root_path
    end

    it "should show welcome box that can be closed" do
      assert_shows_close_link(true)
    end

    it "should have the correct content" do
      assert_shows_welcome_section(true)
    end
    
    context "when clicking close link" do
      before do
        click_close_link
      end

      it "should hide welcome section immediately" do
        assert_welcome_section_is_not_visible
      end

      it "should not show welcome page on refresh" do
        visit root_path
        assert_shows_welcome_section(false)
      end
    end
    
    context "when first user views stream page" do
      before do
        visit logout_path
        login_as(@first_user)
        visit root_path
      end

      it "should show normal welcome section with close link" do
        assert_shows_first_user_badge(false)
        assert_shows_welcome_section(true)
      end
      
      context "when clicking close link" do
        before do
          click_close_link
        end

        it "should hide welcome section immediately" do
          assert_welcome_section_is_not_visible
        end
        
        it "should not show welcome page on refresh" do
          visit root_path
          assert_shows_welcome_section(false)
        end
      end
    end
  end 

  context "when testing inviting users" do
    let!(:user) {login_as(:active_user)}

    before do
      visit invite_users_path(network: user.network)
    end
    
    it "should show invite page" do
      page.current_path.should == invite_users_path(network: user.network)
      page.should have_content "Invite by email"
      page.should have_content "Invite with Yammer"
      page.should have_content "Batch invite"
      page.should have_content "Show Yammer users"

      page.should have_field "user[invitations][]"                
    end
    
    context "when sending an invitation to an email address" do
      before do
        @before_user_count, @before_email_count = User.count, ActionMailer::Base.deliveries.count
        fill_in "user[invitations][]", with: "mary"
        find("div.form-inline input[type=submit][value=Invite]").click
        wait_until_ajax_completes
      end
      
      it "should be back on invite page" do
        page.current_path.should == invite_users_path(network: user.network)
      end
      
      it "should create a user and send an invitation" do
        User.count.should == @before_user_count + 1
        ActionMailer::Base.deliveries.count.should == @before_email_count + 1
      end
      
      it "should say that invitations have been sent" do
        page.should have_content "Successfully sent invitations"
      end
    end
  end

  
  context "when testing avatars" do
    before do
      @user = login_as(:active_user)
      visit edit_user_path(@user)      
    end
    
    it "should not have an avatar" do
      @user.avatar.default?.should be_true
    end
    
    context "and uploading an invalid image file" do
      before do
        page.attach_file("user_avatar", File.join(Rails.root, "app/assets/javascripts/init.js"))
        wait_until_ajax_completes                
      end
      
      it "should show profile edit page" do
        page.current_path.should == edit_user_path(@user)
      end
      
      it "should not show success message" do
        page.should_not have_content "Successfully updated profile"                
      end
      
      it "should still have default avatar" do
        @user.avatar.default?.should be_true
      end
      
    end

    context "and uploading a valid image file" do
      before do
        page.attach_file("user_avatar", File.join(Rails.root, "app/assets/images/badges/100/boss.png"))
        wait_until_ajax_completes                        
        @user.reload
      end

      it "should show profile edit page" do
        page.current_path.should == edit_user_path(@user)
      end
            
      it "should save avatar" do
        path = "/uploads/test/avatar_attachment/#{@user.avatar.id}/file/boss.png"
        @user.avatar.url.should == path
        page.should have_selector("#avatar-wrapper img[src='#{path}']")
      end
      
      it "should not show new avatar in header" do
        page.should_not have_selector("#header-profile-wrapper img[src='/uploads/test/avatar_attachment/#{@user.avatar.id}/file/small_thumb_boss.png']")
      end
      
      context "and then refreshing page" do
        before do
          visit page.current_path
        end
        it "should show new avatar in header" do
          host = Recognize::Application.config.asset_host.present? ? "http://#{Recognize::Application.config.asset_host}" : ""
          page.should have_selector("#header-profile-wrapper img[src='/uploads/test/avatar_attachment/#{@user.avatar.id}/file/small_thumb_boss.png']")
        end
      end
    end
  end

  context "when testing recognitions in user profiles" do
    before do
      @user = FactoryGirl.create(:active_user)      
      @other_user1 = FactoryGirl.create(:active_user)
      @other_user2 = FactoryGirl.create(:active_user)
      @sent_recognition = @user.recognize!(@other_user1, Badge.user_badges.last, "way to go")
      @received_recognition = @other_user2.recognize!(@user, Badge.user_badges.last, "something else")
      @user.reload
      visit user_path(@user)
    end

    it "should show user profile with 3 tabs and a recognize button" do
      page.current_path.should == user_path(@user)

      page.should have_selector("a", text: "RECEIVED")
      page.should have_selector("a", text: "SENT")
      page.should have_selector("a", text: "TEAMS")
      page.should have_link("Recognize #{@user.full_name}")
      page.should have_selector("li.active a#received-trigger")
      page.should have_selector("section#received.active")
    end

    it "should show 1 recognition on received tab" do
      page.should have_selector("section#received div.recognition-card", count: 2)
      page.should have_selector("section#received div#recognition-card-#{@received_recognition.id}")
      page.should have_selector("section#received div.recognition-card img[alt='Thumb ambassador']", count: 1)
      page.should have_selector("section#received div.recognition-card img[alt='Thumb #{@received_recognition.badge.short_name.downcase}']", count: 1)
    end

    it "should show 1 recognition on sent tab" do
      click_link("Sent")
      page.should have_selector("li.active a#sent-trigger")
      page.should have_selector("section#sent.active")
      page.should have_selector("section#sent div.recognition-card", count: 1)
      page.should have_selector("section#sent div#recognition-card-#{@sent_recognition.id}")
      page.should_not have_selector("section#sent div.badge-ambassador", count: 1)
      page.should have_selector("section#sent div.recognition-card img[alt='Thumb #{@sent_recognition.badge.short_name.downcase}']", count: 1)
    end

    context "and a received recognition is made private" do
      before do
        @received_recognition.toggle_privacy!
      end

      it "should be a private recognition" do
        @received_recognition.reload.is_public?.should be_false
      end

      it "should not have private recognition viewable when not logged in" do
        visit user_path(@user)

        page.should have_selector("section#received div.recognition-card", count: 1)
        page.should_not have_selector("div#recognition-card-#{@received_recognition.id}")
        page.should_not have_selector("section#sent div.recognition-card img[alt=#{@sent_recognition.badge.short_name}]", count: 1)
      end

      it "should not have private recognition viewable when logged in as someone from a 3rd party company" do
        login_as(FactoryGirl.create(:active_user))
        visit user_path(@user)
        wait_until_ajax_completes
        
        page.should have_selector("section#received div.recognition-card", count: 1)
        page.should_not have_selector("div#recognition-card-#{@received_recognition.id}")
        page.should_not have_selector("section#sent div.recognition-card img[alt=#{@sent_recognition.badge.short_name}]", count: 1)
      end

      it "should show private recognition when logged in as sender" do
        login_as(@received_recognition.sender)
        visit user_path(@user)
        wait_until_ajax_completes

        page.should have_selector("section#received div.recognition-card", count: 2)
        page.should have_selector("section#received div#recognition-card-#{@received_recognition.id}")
        page.should_not have_selector("section#sent div.recognition-card img[alt=#{@sent_recognition.badge.short_name}]", count: 1)
      end
    end

    context "and a sent recognition is made private" do
      before do
        @sent_recognition.toggle_privacy!
      end

      it "should be a private recognition" do
        @sent_recognition.reload.is_public?.should be_false
      end

      it "should not have private recognition viewable when not logged in" do
        visit user_path(@user)
        click_link("Sent")
        page.should have_selector("li.active a#sent-trigger")
        page.should have_selector("section#sent.active")
        page.should_not have_selector("section#sent div.recognition-card")
      end

      it "should not have private recognition viewable when logged in as a 3rd party" do
        login_as(FactoryGirl.create(:active_user))
        visit user_path(@user)
        click_link("Sent")
        page.should have_selector("li.active a#sent-trigger")
        page.should have_selector("section#sent.active")
        page.should_not have_selector("section#sent div.recognition-card")
      end

      it "should show private recognition when logged in as recipient" do
        @sent_recognition.recipients.should include(@other_user1)
        login_as(@other_user1)
        visit user_path(@user)
        wait_until_ajax_completes
        click_link("Sent")
        page.should have_selector("li.active a#sent-trigger")
        page.should have_selector("section#sent.active")
        page.should have_selector("section#sent div.recognition-card", count: 1)
        page.should have_selector("section#sent div#recognition-card-#{@sent_recognition.id}")
        page.should have_selector("section#sent div.recognition-card img[alt='Thumb #{@sent_recognition.badge.short_name.downcase}']", count: 1)

      end

    end

    context "when changing companies" do
      before do
        @user = FactoryGirl.create(:active_user)
        @old_company = @user.company
        login_as(@user)
        visit root_path
        page.current_path.should == "/#{@user.network}"
        @company = FactoryGirl.create(:company_with_users)
        @user.move_company_to!(@company)
      end

      it "should automatically redirect user" do
        visit root_path
        @user.network.should == @company.domain
        @user.network.should_not == @old_company.domain
        page.current_path.should == "/#{@user.network}"
      end

      it "should redirect user when accessing the old domain" do
        visit "/#{@old_company.domain}"
        page.current_path.should == "/#{@user.network}"
      end
    end

  end
end

def click_close_link
  selector = "div.widget-box .close-icon"
  page.find(selector).click
  expect(page).to_not have_selector(selector)
  # page.execute_script(%Q($('#{selector}').trigger('click')))
  # wait_until_ajax_completes
  # wait_until_page_has_no_selector(selector)
end

def assert_shows_close_link(should=true)
  assertion = should ? "should" : "should_not"
  page.send(assertion, have_selector("div.widget-box .close-icon"))
end

def assert_shows_first_user_badge(should=true)
  assertion = should ? "should" : "should_not"
  if @user.verified?
    page.send("should", have_content("Welcome"))
  else
    page.send(assertion, have_selector("#first-user-welcome.actually-first-user"))
    page.send(assertion, have_selector("#first-user-welcome.actually-first-user div.badge-ambassador"))
    page.send(assertion, have_content("You earned the ambassador badge for starting recognition in your company!"))
  end
end

def assert_welcome_section_is_not_visible
  page.find("#first-user-welcome", visible: false).should_not be_visible
end

def assert_shows_first_user_welcome_section(should=true)
  assertion = should ? "should" : "should_not"
  page.send(assertion, have_selector("#culture"))
  page.send(assertion, have_content("Send a recognition"))
  page.send(assertion, have_content("Invite"))
end

def assert_shows_welcome_section(should=true)
  assertion = should ? "should" : "should_not"
  page.send(assertion, have_selector("#steps"))
  # page.send(assertion, have_content("I want to invite people"))
  # page.send(assertion, have_content("I want to recognize people"))
end