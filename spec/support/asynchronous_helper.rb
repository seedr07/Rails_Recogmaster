require "timeout"
module AsynchronousHelper

  def wait_until(timeout=Capybara.default_max_wait_time)
   Timeout.timeout(timeout) do
      puts "waiting #{timeout}" if ENV['DEBUG'] 
      puts "Anticipated end: #{Time.at(Time.now.to_i + timeout.seconds)}" if ENV['DEBUG'] 
      until(value = yield) do
        sleep(0.1)
      end
      value
    end
  end  

  def wait_until_ajax_completes(timeout=Capybara.default_max_wait_time)
    wait_until(timeout) do
      page.evaluate_script('!jQuery.active')
    end
  end
  
  def wait_until_ajax_starts
    wait_until do
      page.evaluate_script('jQuery.active')
    end
  end
  
  def wait_until_page_has_selector(selector, timeout=Capybara.default_max_wait_time)
    wait_until(timeout) do
      page.evaluate_script("$('#{selector}').is(':visible')")
    end
  end

  def wait_until_page_has_no_selector(selector)
    wait_until do
      page.evaluate_script("!$('#{selector}').is(':visible')")
    end
  end
  
  def wait_until_selector_has_no_class(selector, klass)
    wait_until do
      !page.evaluate_script("$('#{selector}').hasClass('#{klass}')")
    end
  end

  def wait_until_selector_has_class(selector, klass)
    wait_until do
      page.evaluate_script("$('#{selector}').hasClass('#{klass}')")
    end
  end
  
  #The next two methods are inverses of each other where we
  #check the path of the current page according to what javascript sees
  #This method is self explanatory where we wait until a page is at
  #a current path.  The next method is used when you don't know or care
  #where a page is being redirected to but we want to know that we've
  #left the current page(or path that's passed in)
  def wait_until_page_url_is(path)
    wait_until do
      page.current_path == path || page.evaluate_script("window.location.pathname == '#{path}'")
    end
  end
  
  def wait_until_page_is_redirected_from(path, timeout=Capybara.default_max_wait_time)
    wait_until(timeout) do
      page.current_path != path || page.evaluate_script("window.location.pathname != '#{path}'")
    end
  end
  
  def wait_until_remote_events_are_bound
    wait_until do
      page.evaluate_script("window.R.Ajaxify")
    end
  end

  def wait_until_js(js, timeout=Capybara.default_max_wait_time)
    wait_until(timeout) do 
      full_js = "if(#{js}){true} else { false }"
      page.evaluate_script(full_js) == true
    end
  end
  
end