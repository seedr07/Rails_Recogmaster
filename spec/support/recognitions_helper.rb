module RecognitionsHelper
  
  def recognize!(sender, recipients, opts={})
    opts[:badge] ||= sender.company.company_badges.last
    recipients = Array(recipients)
    recognition = sender.recognitions.new(recipients: recipients, badge: opts[:badge], message: "whatever")
    recognition.sender = sender

    if opts[:dont_use_bang_save]
      recognition.save
    else
      recognition.save!
    end

    return recognition
  end

  def assert_sent_recognition!
    # Recognition.count.should == @initial_count + 1
    # page.current_path.should == new_recognition_path
    # ["Badge must be selected", 
    #  "Recipient must be selected from the drop down list or via a company email", 
    #  "Company can't be blank",
    #  "Message can't be blank"].each do |err|
    #   page.should_not have_content_in("body", "li", err)
    # end            
    # 
    # page.should have_content "Your recognition has been sent"
    r = Recognition.unscoped.last
    page.current_path.should == recognition_path(r)
    page.should have_selector(".badge-image")
    page.should have_selector("#recognition-content")
    page.should have_content(r.sender.full_name)
    r.recipients.each do |recipient|
      expect(page).to have_content(recipient.label)
    end
    page.should have_content(r.message)
  end
  
  def recognition_card_selector(recognition)
    "#recognition-card-#{recognition.id}"
  end

  def recognition_edit_btn_selector(r)
    recognition_card_selector(r)+" .recognition-edit"
  end

  def recognition_delete_btn_selector(r)
    recognition_card_selector(r)+" .recognition-delete"
  end

  def ensure_delete_button(r)
    page.should have_selector("#recognition-card-#{r.id}")
    card = page.find(recognition_card_selector(r))
    card.should have_selector(".options-trigger")
    card.find(".options-trigger").click
    card.should have_selector(".recognition-delete")
  end

  def add_recipient(user, name=nil)
    if user.kind_of?(User)
      str = %Q(var o = new window.R.pages["recognitions-new"];o.addRecepient({'id': #{user.id}, email : '#{user.email}', name: '#{user.full_name}'}))
      page.execute_script(str)
    elsif user.kind_of?(Team)
      str = %Q(var o = new window.R.pages["recognitions-new"];o.addRecepient({'id': #{user.id}, 'type': 'Team'}))
      page.execute_script(str)
    else
      name = user if name.nil?
      str = %Q(var o = new window.R.pages["recognitions-new"];o.addRecepient({'email' : '#{user}', name: '#{name}'}))
      page.execute_script(str)
    end
  end
  
  def select_badge
    # agnostic_click("li:first-child.badge-item div.button-small")
    # page.execute_script(%Q($("#recognition_badge_id_1").attr('checked', true)))
    # page.find("#new_recognition #badge-trigger").click 
    page.find("#top .image-wrapper").click
    # screenshot_and_open_image
    page.find("li.badge-item:first-child .button").click         
    sleep 0.33 #sigh...
    wait_until_ajax_completes

  end

  module Session
    
    def on_new_recognition_page?
      errors = false
      errors ||= "Path does not match: expected '#{current_path}' to be '#{new_recognition_path}'" unless current_path == new_recognition_path
      errors ||= "Missing content: Send Recognition" unless !errors and has_content?("Send Recognition")
      errors ||= "Missing selector: #badge-list" unless !errors and has_selector?("#badge-list")
      Badge.user_badges.each{|b| errors ||= "missing badge #{b.name}" unless !errors and has_selector?(".badge-#{b.name}")}
      !errors or raise Capybara::ExpectationNotMet, errors
      return true
    end
    
    def on_recognition_page?(recognition)
      errors = false
      errors ||= "Path does not match: expected '#{current_path}' to be '#{recognition_path(recognition)}'" unless current_path == recognition_path(recognition)
      errors ||= "Missing selector body#recognitions-show" unless !errors and has_selector?("body#recognitions-show")
      errors ||= "Missing content: Name Tags" unless !errors and assert_selector(".nametag",count: 2)
      !errors or raise Capybara::ExpectationNotMet, errors
      return true      
    end
  end
end