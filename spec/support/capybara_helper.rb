module CapybaraHelper
  def agnostic_click(selector)
    #HACK TO GET TOUCH EVENTS TO WORK on capybara-webkit
    #IF USING selenium, it needs to be click event
    case page.driver
    when Capybara::Webkit::Driver
      # page.find(selector).click rescue nil#HACKOLA! some clicks don't have tap...just do both
      # page.execute_script(%Q($("#{selector}").trigger('tap')))
      page.execute_script(%Q($("#{selector}").trigger(R.touchEvent)))
    when Capybara::Selenium::Driver
      page.find(selector).click
    else
      page.find(selector).trigger("click")      
    end
  end
  
  module Session

    def self.included(base)
      base.class_eval do
        alias_method_chain :current_path, :extension
      end
    end

    def current_path_with_extension
      p = current_path_without_extension
      return (p.length > 1 and p.end_with?("/")) ? p.chop : p
    end

    def has_content_in?(outer_wrapper, inner_wrapper, text)
      find(outer_wrapper).has_selector?(inner_wrapper, text: text)
    end

    def on_stream_page?(user = User.last)
      errors = false
      errors ||= "Path does not match: #{current_path}" unless current_path == stream_path(user.network)
      errors ||= "Missing content: Recognitions" unless !errors and has_content?("Recognition")
      errors ||= "Missing selector: #stream" unless !errors and has_selector?("#stream")
      !errors or raise Capybara::ExpectationNotMet, errors
      return true
    end  
    
    def ss
      screenshot_and_open_image
    end  
  end
end