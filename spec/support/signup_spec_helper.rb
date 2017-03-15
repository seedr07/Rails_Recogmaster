module SignupSpecHelper
  def click_on_team_btn(name)
    # page.execute_script("$(\"input[type=checkbox][value='#{name}']\").parents('label').find('div.button').click()")
    # page.find("input[type=checkbox][value='#{name}']+div.button").click
    agnostic_click("input[type=checkbox][value='#{name}']+div.button")
  end
    
  def assert_shows_welcome_page_section(section)
    case section
    when :name
      page.should have_selector("#name.current")
      
      page.should_not have_selector("#teams.current")
      page.should_not have_selector("#invite.current")
    when :teams
      page.should_not have_selector("#name.current")
      page.should have_selector("#teams.current")
      page.should_not have_selector("#invite.current")
    when :invites
      page.should_not have_selector("#name.current")
      page.should_not have_selector("#teams.current")
      page.should have_selector("#invite.current")
    end
  end

  module Session
    def has_form_showing?(tab)
      case tab
      when :home
        has_selector?("#banner.current") and 
        !find("#full_name-wrapper", visible: false).has_css?(".current") and 
        !find("#password-wrapper", visible: false).has_css?(".current")        
      when :full_name
        !find("#banner", visible: false).has_css?(".current") and
        has_selector?("#full_name-wrapper.current") and
        !find("#password-wrapper", visible: false).has_css?(".current")              
      when :password
        !find("#banner.home-form", visible: false).has_css?(".current") and
        !find("#full_name-wrapper", visible: false).has_css?(".current") and 
        has_selector?("#password-wrapper.current")            
      end
    end  

  end
end