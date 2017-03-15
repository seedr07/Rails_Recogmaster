  require 'spec_helper'

describe "Signup" do
  include SignupSpecHelper
  Capybara::Session.send(:include, SignupSpecHelper::Session)
  Capybara::Session.send(:include, RecognitionsHelper::Session)
  
  ###############################################################
  #
  # When accessing home page
  #
  ###############################################################
  context "when accessing home page", js: true do
    before do
      visit sign_up_path
      wait_until_remote_events_are_bound
    end

    it "should show form to sign In" do
      page.should have_selector("form#new_user")
      page.should have_button("Sign up")
      
    end

    ###############################################################
    #
    # When accessing home page and clicking signup without email
    #
    ###############################################################
    context "when clicking signup without email" do
      before do
        within "section#banner form" do
          click_on "Sign up"
        end
        wait_until_ajax_completes
      end
      
      it "should still show home email signup form" do
        page.should have_form_showing(:home)
      end

      it "should hide full name form" do
        page.should_not have_form_showing(:full_name)
      end
      
      it "should hide password form" do
        page.should_not have_form_showing(:password)
      end
      
      it "should show error message" do
        page.should have_selector("div.error h5", count: 1)
      end
        
    end

    ###############################################################
    #
    # When accessing home page and clicking signup without proper email
    #
    ###############################################################    
    context "when clicking signup without proper email" do
      before do
        fill_in "user_email", with: "notaproperemail@.com"
        within "section#banner form" do
          click_on "Sign up"
        end
        wait_until_ajax_completes
      end
      
      it "should still show home email signup form" do
        page.should have_form_showing(:home)
      end

      it "should hide full name form" do
        page.should_not have_form_showing(:full_name)
      end
      
      it "should hide password form" do
        page.should_not have_form_showing(:password)
      end
    end

    ###############################################################
    #
    # When accessing home page and clicking signup email that is 
    #  not proper because its just bunch of words
    #
    ###############################################################    
    context "when clicking signup without proper email" do
      before do
        fill_in "user_email", with: "Not an email"
        within "section#banner form" do
          click_on "Sign up"
        end
        wait_until_ajax_completes
      end
      
      it "should still show home email signup form" do
        page.should have_form_showing(:home)
      end

      it "should hide full name form" do
        page.should_not have_form_showing(:full_name)
      end
      
      it "should hide password form" do
        page.should_not have_form_showing(:password)
      end
    end
    
    ###############################################################
    #
    # When accessing home page and clicking signup with email on blacklist
    #
    ###############################################################    
    context "when clicking signup with email from domain on blacklist" do
      include EmailBlacklist
      before do
        FactoryGirl.create(:company, name: "Users", domain: "users") unless Company.exists?(domain: "users")
        @blacklist_domain = email_blacklist[rand(email_blacklist.length-1)]
        @email = "bob@#{@blacklist_domain}"
        fill_in "user_email", with: @email
        within("form#new_user"){click_on "Sign up"}
        wait_until_ajax_completes
      end
      
      it "should not show error messages" do
        page.should_not have_selector("div.error h5", count: 1)
      end

      it "should still be on the home page and show password form" do
        page.current_path.should == sign_up_path
        page.should have_form_showing(:full_name)
        page.should_not have_form_showing(:password)
      end

      context "and submitting name and password" do
        before do
          page.should have_form_showing(:full_name)
          within("form#full_name_form") do
            fill_in "user_first_name", with: "Bob"
            fill_in "user_last_name", with: "Dole"
            click_on "Next"
          end
          wait_until_ajax_completes

          page.should have_form_showing(:password)
          within("form#user_password_form") do
            fill_in "user_password", with: "abcdefg"
            click_on "Join"
          end
          wait_until_page_is_redirected_from(sign_up_path)
        end

        it "should not show certain links" do
          page.current_path.should == user_path(User.last)
          page.should_not have_content "Login"

          within("#header-controls") do
            page.should_not have_selector "header-stream"
            page.should_not have_selector "header-reports"
          end
          within("#header-settings") do
            page.should_not have_selector "li.teams"
          end

        end
      end
    end

    ###############################################################
    #
    # When accessing home page and clicking signup with existing email
    #
    ###############################################################    
    context "when clicking signup with existing email" do
      before do
        @user = FactoryGirl.create(:user)
        fill_in "user_email", with: @user.email
        within "section#banner .form-wrapper" do
          click_on "Sign up"
        end
        wait_until_ajax_completes(10)
      end
      
      it "should show error messages" do
        page.should have_selector("div.error h5", count: 1)
      end
    end

    ###############################################################
    #
    # When accessing home page and clicking signup with existing email
    # of first user that does not have a password set
    #
    ###############################################################    
    context "when clicking signup with existing email of first user that does not have a password set" do
      before do
        @user = User.create(email: FactoryGirl.generate(:email), first_name: "Sam", last_name: "Jackson")
        fill_in "user_email", with: @user.email
        within "section#banner .form-wrapper" do
          click_on "Sign up"
        end
        wait_until_ajax_completes
      end

      it "should show error messages" do
        page.should have_selector("div.error h5", count: 1, text: "If this is you, you may reset your password")
      end      
      # it "should not show error messages" do
      #   page.should_not have_selector("div.form-errors")
      # end
      # 
      # it "should show form for company name" do
      #   page.should have_form_showing(:company)
      # end
      # 
      # it "should prefill company name with domain from email" do
      #   page.should have_field "user_company_attributes_name", with: "recognizeapp#{@unique}"
      # end            
    end        
    
    ###############################################################
    #
    # When accessing home page and clicking signup with existing email
    # of non-first user that does not have a password set
    #
    ###############################################################    
    context "when clicking signup with existing email of non-first user that does not have a password set" do
      before do
        @first_user = FactoryGirl.create(:active_user)
        @user = User.create(email: "blah@#{@first_user.company.domain}", first_name: "Sam", last_name: "Jackson")
        
        fill_in "user_email", with: @user.email
        within "section#banner .form-wrapper" do
          click_on "Sign up"
        end
        wait_until_ajax_completes
      end

      it "should show error messages" do
        page.should have_selector("div.error h5", count: 1, text: "If this is you, you may reset your password")
      end         
      # it "should be on the confirm email page" do
      #   page.current_path.should == confirm_email_signups_path
      # end
      
    end        

    
    ###############################################################
    #
    # When accessing home page and clicking signup with proper email on new domain
    #
    ###############################################################        
    context "when clicking signup with proper email on new domain" do 
      before do
        @unique = FactoryGirl.generate(:count).to_s.gsub('.','')
        @email = "email#{@unique}@recognizeapp#{@unique}.com"
        fill_in "user_email", with: @email
        within("form#new_user"){click_on "Sign up"}
        wait_until_ajax_completes
        sleep 0.5
      end
      
      it "should show form for full name" do
        page.should have_form_showing(:full_name)
      end
      
      it "should prefill company name with domain from email" do
        page.should have_field "user_first_name"
        page.should have_field "user_last_name"
      end

      ###############################################################
      #
      # When accessing home page and clicking signup with proper email
      #   and clicking next when company name is blank
      #
      ###############################################################        
      context "when clicking next when company name is blank" do
        before do
          fill_in "user_first_name", with: ""
          fill_in "user_last_name", with: ""
          within("form#full_name_form"){click_on "Next"}          
          wait_until_ajax_completes
        end
        
        it "should show error message" do
          page.should have_selector("div.error h5", count: 2)
        end
      end

      ###############################################################
      #
      # When accessing home page and clicking signup with proper email
      #   and clicking next with a valid company name
      #
      ###############################################################              
      context "when clicking next with a valid full name" do
        before do
          @perishable_token = User.find_by_email(@email).perishable_token
          fill_in "user_first_name", with: "Don"
          fill_in "user_last_name", with: "Corleone"
          within("form#full_name_form"){click_on "Next"}
          wait_until_ajax_completes
          sleep 1
        end
        
        it "should show form for password" do
          page.should have_form_showing(:password)
        end

        #I know, I know, this is so not a proper test in feature land...
        #but we need to know if we've updated the perishable token
        #which happens automatically by Authlogic
        it "should not update perishable token" do
          User.find_by_email(@email).perishable_token.should == @perishable_token
        end
        
        it "should show toggle switch for showing password" do
          page.should have_content "Show Password"
        end

        ###############################################################
        #
        # When accessing home page and clicking signup with proper email
        #   and clicking next with a valid company name
        #   and clicking next without a valid password
        #
        ###############################################################              
        context "when clicking next without a password" do
          before do
            within("form#user_password_form"){click_on "Join"}
            wait_until_ajax_completes
          end

          it "should show error message" do
            page.should have_selector("div.error h5", count: 1)
          end          
        end
        
        ###############################################################
        #
        # When accessing home page and clicking signup with proper email
        #   and clicking next with a valid company name
        #   and clicking next with a valid password
        #
        ###############################################################
        shared_examples_for "welcome steps page" do
          it 'shows welcome steps page' do
            sleep 1
            expect(page.current_path).to eq(welcome_path(network: @user.network))         
            expect(page).to have_css("#welcome-wrapper")
          end
        end              
        context "when clicking next with a valid password" do
          before do
            within("form#user_password_form") do
              fill_in "user_password", with: "abcdefg"
              click_on "Join"
            end
            wait_until_ajax_completes
            @user = User.where(email: @email).first
          end

          it_behaves_like "welcome steps page"        
          
          it "should not show login link" do
            page.should_not have_content "Login"
          end

          context "after verifying" do
            before do
              expect(@user.reload.verified?).to be_false              
              visit verify_signup_path(@user.perishable_token)              
            end

            it 'still verifies user and shows stream page' do
              expect(@user.reload.verified?).to be_true
              expect(page.current_path).to eq("/#{@user.network}")
            end

            context 'and revisiting welcome page' do
              before do
                expect(@user.reload.verified?).to be_true
                visit welcome_path(network: @user.network)                
              end

              it_behaves_like "welcome steps page"        

            end
          end
        end#end when clicking next with valid password
      end#end when clicking next with valid company name
    end

    ###############################################################
    #
    # When accessing home page and clicking signup with proper email on new domain
    #
    ###############################################################    
    context "when clicking signup with email on existing domain" do
      before do
        @first_user = FactoryGirl.create(:user)
        @company = @first_user.company
        @domain = @first_user.email.split("@")[1]
        fill_in "user_email", with: "email#{FactoryGirl.generate(:count)}@#{@domain}"
        within("form#new_user"){click_on "Sign up"}
        wait_until_ajax_completes
        sleep 1.5        
      end
      
      it "should show user thanks for signing up, please confirm your email page" do
        page.current_path.should == confirm_email_signups_path
      end
      
      ###############################################################
      #
      # When accessing home page and clicking signup with proper email on existing domain
      #   and user visits email verification url
      #
      ###############################################################    
      context "and user visits email verification url" do
        before do
          @user = User.last
          visit verify_signup_path(@user.perishable_token)
          wait_until_remote_events_are_bound
          sleep 1.5
        end
        
        it "should show user home page with enter password form" do
          page.current_path.should == "/sign-up"
        end

        it "should show password form" do
          page.should have_form_showing(:full_name) 

          form = page.find("form#full_name_form")
          form.should have_selector "input#full_name-hidden-email[type=hidden]", visible: false
          form.find("input#full_name-hidden-email[type=hidden]", visible: false).value.should == @user.email
        end

        # it "should show password form" do
        #   page.should have_form_showing(:password) 

        #   form = page.find("form#user_password_form")
        #   form.should have_selector "input#password-hidden-email[type=hidden]", visible: false
        #   form.find("input#password-hidden-email[type=hidden]", visible: false).value.should == @user.email
        # end
        ###############################################################
        #
        # When accessing home page and clicking signup with proper email on existing domain
        #   and user visits email verification url
        #   and then saves password
        #
        ###############################################################            
        context "and then saves name and password" do
          before do
            wait_until_page_has_selector("form#full_name_form")
            within("form#full_name_form") do
              fill_in "user_first_name", with: "Hilary"
              fill_in "user_last_name", with: "Clinton"
              click_on "Next"
            end

            wait_until_ajax_completes

            within("form#user_password_form") do
              fill_in "user_password", with: "abcdefg"
              click_on "Join"
            end

            wait_until_ajax_completes             
          end

          it "should redirect to welcome page" do
            expect(page.current_path).to eq(welcome_path(network: @user.network))
          end
        
          it "should not show login link" do
            page.should_not have_content "Login"
          end
 
        end

      end
      
    end
    
  end
      
  ###############################################################
  #
  # When accessing tour page and filling out email and clicking signup
  #
  ###############################################################    
  context "when filling out email form on tour page and clicking signup", js: true do
    before do
      visit tour_path
      wait_until_remote_events_are_bound
      sleep 1.5
    end
    
    it "should show tour page" do
      page.current_path.should == tour_path
    end
    
    ###############################################################
    #
    # When accessing tour page and filling out email and clicking signup
    #   and email is from new domain
    #
    ###############################################################    
    context "and email is from a new domain" do
      before do
        within "form#new_user" do
          fill_in "user_email", with: "email@recognizeapp#{FactoryGirl.generate(:count)}.com"
        end
        within "section#banner .form-wrapper" do
          click_on "Sign up"
        end
        wait_until_ajax_completes
        sleep 0.5                
      end
      
      it "should keep user on tour page" do
        page.current_path.should == tour_path
      end
      
      it "should show user form to enter full name" do
        page.should have_form_showing(:full_name)
      end
    end

    ###############################################################
    #
    # When accessing tour page and filling out email and clicking signup
    #   and email is from existing domain
    #
    ###############################################################       
    context "and email is from an existing domain" do
      before do
        @user = FactoryGirl.create(:user)
        within "form#new_user" do
          fill_in "user_email", with: "email#{FactoryGirl.generate(:count)}@#{@user.company.domain}"
        end
        within "section#banner .form-wrapper" do
          click_on "Sign up"
        end
        wait_until_ajax_completes
        sleep 0.5                
        
      end
      
      it "should be on the email confirm page" do
        page.current_path.should == confirm_email_signups_path
      end
      
    end
  end

  ###############################################################
  #
  # When signing up from an invitation and visiting verify_signup_url
  #
  ###############################################################        
  context "when signing up from an invitation", js: true do
    before do
      @user = FactoryGirl.create(:user)
    end
    
    ###############################################################
    #
    # When signing up from an invitation and visiting verify_signup_url
    #   and has available user accounts
    #
    ###############################################################        
    context "and has available user accounts" do
      before do
        @new_user = @user.invite!("somenewuser")[0]
        visit verify_signup_path(@new_user.perishable_token)
        wait_until_page_is_redirected_from(@new_user.perishable_token)
        sleep 1.5
      end
    
      it "should be on the homepage asking to enter full name" do
        page.current_path.should == "/sign-up"
        page.should have_form_showing(:full_name)
      end

      context "and revists verify url before entering password" do
        before do
          visit verify_signup_path(@new_user.perishable_token)          
          wait_until_page_is_redirected_from(@new_user.perishable_token)
        end
        
        it "should take them to the forgot password page" do
          page.current_path.should == new_password_reset_path
          page.should have_content "expired"
        end        
      end
      
      ###############################################################
      #
      # When signing up from an invitation and visiting verify_signup_url
      #   and has available user accounts
      #   and entering password   
      #
      ###############################################################          
      context "and entering name and password" do
        before do
          within("form#full_name_form") do
            fill_in "user_first_name", with: "Michael"
            fill_in "user_last_name", with: "Jordan"
            click_on "Next"
          end
          wait_until_ajax_completes

          within("form#user_password_form") do
            fill_in "user_password", with: "abcdefg"
            click_on "Join"
          end
          wait_until_ajax_completes
        end

        it "should be on stream page" do
          expect(page.current_path).to eq(welcome_path(network: @user.network))
        end
      
        it "should not show login link" do
          page.should_not have_content "Login"
        end
      end
    end
  end
  
  context "when trying to verify an email for the 1st user for a company", js: true do
    before do
      @user = FactoryGirl.create(:active_user)
      @user.update_attribute(:verified_at, nil)
    end

    context "and they are not already logged in" do
      before do
        visit edit_password_reset_path(@user.perishable_token)

        fill_in "New Password", with: "newpassword123"
        click_on "Update my password and log me in"
        wait_until_page_is_redirected_from password_resets_path
      end

      it "should take them to the stream page" do
        page.current_path.should == stream_path(@user.network)
        page.should have_selector("body#recognitions-index")
      end
    end
    
    context "and they are logged in" do
      before do
        login_as(@user)

        visit edit_password_reset_path(@user.perishable_token)

        fill_in "New Password", with: "newpassword123"
        click_on "Update my password and log me in"
        wait_until_page_is_redirected_from password_resets_path
      end
      
      it "should take them to the home page" do
        page.current_path.should == stream_path(@user.network)        
        page.should have_selector("body#recognitions-index")
      end
    end
  end
end