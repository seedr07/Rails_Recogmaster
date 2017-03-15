module DateRangeHelper
  def self.included(subclass)
    subclass.send(:include, IntervalHelper)
    subclass.send(:include, Select2Helper)
    subclass.send(:include, DateTimeHelper)
  end

  def default_interval
    Interval.new(company.reset_interval)
  end

  def default_interval_label
    shifted_interval_label(default_interval, Time.now, 0)
  end

  def selected_wrapper
    page.find(".date-range-select.active")
  end

  def expect_interval_is_unselected(interval)
    click_on_interval reset_interval_noun(interval).humanize
    expect(selected_wrapper[:class]).to include("date-range-select-#{interval.to_i}")
    expect(selected_wrapper).to have_content("Please select an option")
  end

  def expect_interval_is_selected(interval, value)
    click_on_interval reset_interval_noun(interval).humanize
    expect(selected_wrapper[:class]).to include("date-range-select-#{interval.to_i}")
    # expect(selected_wrapper.base.inner_html).to have_content(value)   
    expect(selected_wrapper).to have_content(value)
  end

  def expect_select_to_change_to(interval, time)
    label = shifted_interval_label(interval, time, 0)
    start_date = interval.start(time: time)
    end_date = interval.end(time: time)
    value = IntervalHelper::DateRangePresenter.new(nil,nil,param_scope,nil).query_string(start_date, end_date, interval)

    selector = ".date-range-select-#{interval.to_i} select"

    click_on_interval reset_interval_noun(interval).humanize
    select2(value, from: container+" "+selector)
    wait_until_ajax_completes
    expect_interval_is_selected(interval, label)
  end

  def expect_custom_range_to_be(start_date, end_date)
    click_on_interval "Custom"
    selector = ".date-range-select-#{Interval.custom.to_i}"

    start_date = localize_datetime(start_date, :slash_date) if start_date.kind_of?(Time)
    end_date = localize_datetime(end_date, :slash_date) if end_date.kind_of?(Time)

    expect(selected_wrapper[:class]).to include(selector.gsub(/^\./, ''))
    within selector do 
      expect(page).to have_field "from", with: start_date
      expect(page).to have_field "to", with: end_date
    end

  end

  def expect_custom_range_to_change_to(start_date, end_date)
    click_on "Custom"
    selector = ".date-range-select-#{Interval.custom.to_i}"

    start_date = localize_datetime(start_date, :slash_date)
    end_date = localize_datetime(end_date, :slash_date)

    within selector do 
      fill_in "from", with: start_date
      fill_in "to", with: end_date
      click_on "Go"
    end

    expect_custom_range_to_be(start_date, end_date)
  end

  def click_on_interval(name)
    begin
      click_on name
    rescue Capybara::Webkit::ClickFailed => e
      evaluate_script "$('a:contains(\"#{name}\").click()')"
    end
  end
end