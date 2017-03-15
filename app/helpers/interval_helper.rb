module IntervalHelper
  include DateTimeHelper

  def interval_points(user, grammar = :noun)
    content_tag(:div, class: "interval_points") do
      content_tag(:span, reset_interval_label(user.reset_interval).humanize+ " "+I18n.t('dict.points')+" ", class: "point-interval-label") +
      content_tag(:span, user.interval_points, class: "point-interval")
    end
  end

  Q1, Q2, Q3, Q4 = [1,2,3,4,5,6,7,8,9,10,11,12].each_slice(3).to_a
  def reset_interval_label(interval, time = Time.now)
    label = case
    when interval.daily?
      I18n.t("interval.day", prefix: nil)
    when interval.weekly?
      I18n.t("interval.week", prefix: nil)
    when interval.monthly?
      I18n.localize(time, format: "%B")
    when interval.quarterly?
      quarter = (time.month / 3.0).ceil
      I18n.t('interval.q', quarter: quarter)
    when interval.yearly?
      time.strftime("%Y")
    end
    return label.html_safe
  end

  def reset_interval_label_with_time(interval, time = Time.now)
    label = case
    when interval.daily?
      if time >= 1.day.ago
        I18n.t("dict.yesterday")
      else
        # "#{time.strftime('%Y-%m-%d')}"
        localize_datetime(time, :slash_date)
      end
    when interval.weekly?
      if time >= 1.week.ago
        I18n.t("dict.last_week")
      else
        localize_datetime(time, :slash_date)
        # "#{time.strftime('%Y-%m-%d')}"
      end
    when interval.monthly?
      I18n.localize(time, format: "%B")
    when interval.quarterly?
      quarter = (time.month / 3.0).ceil
      I18n.t('interval.q_with_year', quarter: quarter, year: time.year)
    when interval.yearly?
      time.strftime("%Y")
    end
    return label.html_safe
  end

  def shifted_interval_label(interval, time, shift)
    time = interval.shift(time: time, shift: shift)

    label = case
    when interval.daily?
      "#{time.beginning_of_day.strftime("%Y-%m-%d")}"
    when interval.weekly?
      "#{time.beginning_of_week.strftime("%Y-%m-%d")}"
    when interval.monthly?
      I18n.localize(time, format: "%B %Y")
    when interval.quarterly?
      quarter = (time.month / 3.0).ceil
      I18n.t('interval.q_with_year', quarter: quarter, year: time.year)
    when interval.yearly?
      I18n.localize(time, format: "%Y")
    end
    return label.html_safe
  end

  def reset_interval_adverb(interval)
    label = case
    when interval.daily?
      I18n.t("interval.daily")
    when interval.weekly?
      I18n.t("interval.weekly")
    when interval.monthly?
      I18n.t("interval.monthly")
    when interval.quarterly?
      I18n.t("interval.quarterly")
    when interval.yearly?
      I18n.t("interval.yearly")
    end
    return label.html_safe
  end

  def reset_interval_noun(interval, prefix=nil)
    label = case
    when interval.custom?
      I18n.t("interval.custom", prefix: prefix)
    when interval.daily?
      I18n.t("interval.day", prefix: prefix)
    when interval.weekly?
      I18n.t("interval.week", prefix: prefix)
    when interval.monthly?
      I18n.t("interval.month", prefix: prefix)
    when interval.quarterly?
      I18n.t("interval.quarter", prefix: prefix)
    when interval.yearly?
      I18n.t("interval.year", prefix: prefix)
    end
    return label.html_safe
  end

  def interval_options_for_select(selected, prefix=nil)
    excludes = [Interval::DAILY]
    intervals = Interval::RESET_INTERVALS.map{|id, label|
      next if excludes.include?(id)
      interval = Interval.new(id)
      [reset_interval_noun(interval, prefix), id]
    }
    options_for_select(intervals.reject(&:blank?), selected)
  end

  def date_range_presenter(param_scope)
    DateRangePresenter.new(current_user, self, param_scope, params)
  end

  class DateRangePresenter
    attr_reader :user, :template, :param_scope, :params

    def initialize(user, template, param_scope, params)
      @user = user
      @template = template
      @param_scope = param_scope
      @params = params
    end

    def company
      user.company
    end

    def scoped_params
      param_scope.present? ? (params[param_scope] || {}) : params
    end

    def start_date
      @start_date ||= scoped_params[:start_date].present? ? Time.at(scoped_params[:start_date].to_i) : selected_interval.start
    end

    def end_date
      @end_date ||= scoped_params[:end_date].present? ? Time.at(scoped_params[:end_date].to_i) : selected_interval.end
    end

    def selected_interval
      Interval.new(scoped_params[:interval] || company.reset_interval)
    end

    def interval_buttons
      template.content_tag "nav", class: "tab-nav marginTop0 marginBottom5" do
        template.content_tag "ul", class: "clearfix" do
          template.concat interval_button(Interval.monthly)
          template.concat interval_button(Interval.quarterly)
          template.concat interval_button(Interval.yearly)
          template.concat interval_button(Interval.custom)
        end
      end
    end

    def interval_button(interval)
      css_class = " #{'active' if selected_interval == interval}"
      template.content_tag "li", class: css_class do
        template.link_to template.reset_interval_noun(interval).humanize, ".date-range-select-#{interval.to_i}", data: {interval: interval.to_i, toggle: "tab"}
      end
    end

    def custom_date_range_selector
      input_opts = {type: "text", class: "form-control datepicker", placeholder: template.t("forms.ddmmyyyy")}
      css_class = "date-range-select date-range-select--1 #{'active' if selected_interval == Interval.custom}"

      start_value = selected_interval.custom? ? template.localize_datetime(start_date, :slash_date) : nil
      end_value = selected_interval.custom? ? template.localize_datetime(end_date, :slash_date) : nil

      template.content_tag(:div, class: css_class) do
        template.concat template.tag(:input, input_opts.merge({name: "from", value: start_value}))
        template.concat template.tag(:input, input_opts.merge({name: "to", value: end_value}))
        template.concat template.tag(:input, type: "submit", value: "Go", class: "button button-primary")
      end
    end

    def selected_date_range_heading
      if selected_interval.custom?
        template.content_tag(:h3) do
          "#{template.localize_datetime(start_date,:slash_date)} - #{template.localize_datetime(end_date, :slash_date)}"
        end
      else
        template.content_tag(:h2) do
          template.shifted_interval_label(selected_interval, start_date, 0)
        end
      end
    end

    def interval_select(interval)
      css_class = "date-range-select date-range-select-#{interval.to_i} #{'active' if selected_interval == interval}"
      template.content_tag "div", class: css_class do
        template.select_tag "", date_range_interval_options(interval)
      end
    end

    def date_range_interval_options(interval)
      if scoped_params[:interval].blank?
        selected_str = query_string(selected_interval.start, selected_interval.end, selected_interval)
        # selected_str = "start_date=#{selected_interval.start.to_i}&end_date=#{selected_interval.end.to_i}&interval=#{selected_interval.to_i}"
      else
        selected_str = query_string(scoped_params[:start_date], scoped_params[:end_date], scoped_params[:interval])
        # selected_str = "start_date=#{params[:start_date]}&end_date=#{params[:end_date]}&interval=#{params[:interval]}"
      end

      selected = nil
      options = date_range_intervals(interval).map do |t|
        start_t = t.to_i
        end_t = interval.end(time: t).to_i
        option_str = query_string(start_t, end_t, interval)
        selected  ||= option_str if option_str == selected_str
        [ template.shifted_interval_label(interval, t, 0), option_str]
      end
      options.unshift(["Please select an option",""])
      template.options_for_select(options, disabled: "", selected: selected || '')
    end

    def date_range_intervals(interval)
      current_interval = interval.start
      intervals = [current_interval]

      while(current_interval > company.created_at) do
        current_interval = interval.shift(shift: -1, time: current_interval)
        intervals << current_interval
      end
      intervals
    end

    def query_string(start_date, end_date, interval)
      start_date = start_date.to_i
      end_date = end_date.to_i
      interval = interval.to_i
      if param_scope.present?
        "#{param_scope}[start_date]=#{start_date}&#{param_scope}[end_date]=#{end_date}&#{param_scope}[interval]=#{interval}"
      else
        "start_date=#{start_date}&end_date=#{end_date}&interval=#{interval}"
      end
      # "start_date=#{start_date.to_i}&end_date=#{end_date.to_i}&interval=#{interval.to_i}"
    end
  end
end
