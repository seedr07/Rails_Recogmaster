module ApplicationHelper
  #re: page_name, js_class helpers
  #these drop variables into the <body> tag of the layout(note: there are multiple layouts: application, user_stream)
  #here we opt to use content_for rather than a before filter
  #the idea is that we want the views to determine what variables to drop.  
  #this may seem not dry, and you need to specify the same thing in multiple views, but its more explicit
  #and as well, we avoid the problem where we have to worry about which view is rendered in which action
  #so if an action changes the view, then we need to update the before_filter as well
  #this way, whichever action needs to render a view, we'll drop the variables that apply to that view
  #and are worry free!

  SHORT_LANGUAGES = ["en", "en-GB"]
  def is_long_language_css_klass
    if current_user && !SHORT_LANGUAGES.include?(current_user.locale)
      "long-language"
    end
  end


  def js_class
    content_for(:js_class)
  end
  
  def content_for_stream_page
    content_for(:page_name) {"stream"}
    content_for(:js_class) {"Stream"}
  end
  
  VOWELS = ["a", "e", "i", "o", "u", "y"]
  def add_preceding_article(string)
    article = VOWELS.include?( string[0].downcase ) ? "an" : "a" 
    "#{article} #{string}"
  end

  def render_flash(opts={})
    locals = {flash: flash, include_errors: opts[:include_errors]}
    render partial: "layouts/flash", locals: locals
  end
  
  #passed in user can be a User object or a UserLite object
  #as long as it responds to slug
  def link_to_user(user, opts={})
    avatar = AvatarAttachment.find_by_owner_id(user.id)
    img = image_tag(avatar.small_thumb, class: "profile-pic pull-left", style: "height:20px;padding-right:5px") if avatar
    link_to img.to_s+user.full_name, user_path(user.slug, network: user.network)
  end
  
  def user_recognition_path(user, opts={})
    o = {recipient: user.slug, recipient_network: user.network}.merge(opts)
    new_recognition_path(o)
  end
  
  def user_recognition_url(user, opts={})
    chromeless = opts.delete(:chromeless)

    if user.persisted?
      o = {recipient: user.slug, recipient_network: user.network}
    else
      o = {recipient: {email: user.email, first_name: user.first_name, last_name: user.last_name}}
    end

    o[:recipient_yammer_id] = user.yammer_id if user.yammer_id.present?
    o.merge!(opts)

    chromeless ? new_chromeless_recognitions_url(o) : new_recognition_url(o)
  end
  
  def link_to_yammer(text = "Sign in with Yammer", opts={})
    params = {provider: "yammer"}.merge(opts[:params] || {})
    class_names = opts[:class].present? ? "#{opts[:class]}" : "button-yammer-signup button"
    link_to text, remote_auth_url(params), class: class_names
  end

  def link_to_google(text = "Sign in with Google", opts={}, &block)
    if block_given?
      link_to remote_auth_url( {:provider => "google_oauth2"}), opts do
        yield
      end
    else
      link_to text, remote_auth_url( {:provider => "google_oauth2"}), opts
    end
    
  end

  def link_to_o365(text = "Sign in with Office 365", opts={}, &block)
    class_names = (opts[:button] == false) ? "#{opts[:class]}" : "button #{opts[:class]}"
    class_names << " o365-auth-link" if sharepoint_viewer?

    options = {}
    options[:class] = class_names
    options[:target] = "_blank" if sharepoint_viewer?

    link_to text, remote_auth_url(provider: :office365), options
  end
  
  def link_to_saml(text = t('saml.sign_in'), opts = {})
    class_names = opts[:class].present? ? "#{opts[:class]}" : "button"
    url_opts = opts[:network].present? ? {network: opts[:network]} : {}
    link_to text, sso_saml_index_path(url_opts), {class: class_names}
  end

  def is_live_production_server?
    Recognize::Application.config.host == "recognizeapp.com"
  end
  
  def use_production_analytics?
    (is_live_production_server? and Rails.env.production? and (!current_user or (current_user and current_user.company.domain != "recognizeapp.com")))
  end

  def time_from_yearweek(yearweek)
    m = yearweek.to_s.match(/^([0-9]{4})([0-9]{2})$/)
    year, week = m[1].to_i, m[2].to_i
    Date.commercial(year, week).to_time.to_i*1000
  end

  def percent(count, total)
    p = (count / total.to_f)*100
    precision = p < 1 ? 2 : 0
    number_to_percentage(p, precision: precision)
  end

  def show_toggle(condition, title, opts={})
    render partial: "layouts/toggle", locals: {condition: condition, title: title, opts: opts}
  end

  def formatted_price(price)
    if price.present?
      "%g" % (price / 1.0)
    end
  end

  def company_teams_json
    (@company && @company.teams.present? ? @company.teams : []).to_json.html_safe
  end

  def has_theme?
    current_user.present? && current_user.company.present? && current_user.company.has_theme?
  end

  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", form: builder)
    end
    link_to(name, 'javascript://', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
  end

  def body_classes
    classes = []
    classes << page_class
    classes << is_long_language_css_klass
    classes << "logout" if !current_user
    classes << "has-theme" if has_theme?
    classes << "viewer-#{params[:viewer]}" if params["viewer"].present?
    classes << "subscription-active" if current_user && current_user.subscribed_account?
    classes.join(" ")
  end

  def company_family_set(company = @company)
    company.family.map{|c| [c.name, c.domain] }    
  end

  def company_family_options_for_select(company = @company)
    options_for_select(company_family_set(company), (params[:dept] || current_user.network))
  end

  def user_path(*args)
    obj = args[0]
    if obj.kind_of?(User)
      opts = {network: obj.network}
      opts.merge!(args[1]) if args[1].kind_of?(Hash)
      super(obj.slug, opts)
    else
      super
    end
  end

  def user_url(*args)
    obj = args[0]
    if obj.kind_of?(User)
      opts = {network: obj.network}
      opts.merge!(args[1]) if args[1].kind_of?(Hash)
      super(obj.slug, opts)
    else
      super
    end    
  end

  def show_upgrade_banner?
    @show_upgrade_banner
  end

  def formatted_phone(phone)
    return nil unless phone.present?
    return phone if Recognize::Application.twilio_client.kind_of?(Recognize::Application::TwilioMockClient)
    
    return Twilio::PhoneNumber.format(phone)
  end

  def sending_limit_scope_select(name, selected = nil, opts={})
    if @company.allow_send_limit_scope_selection?
      # options = options_for_select([["Recognitions", Recognition::SCOPE_LIMIT_BY_RECOGNITIONS, ], ["Recipients", Recognition::SCOPE_LIMIT_BY_USERS]]) 
      options = options_for_select(Recognition::LimitScope.options_for_select, selected)
      style = @company.allow_nominations? ? "display: none;width:150px;" : "width: 150px;"
      select_tag(name, options, opts.merge({style: style}))
    end
  end
end
