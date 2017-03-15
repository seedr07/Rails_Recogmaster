module MetaHelper
  def title
    t = content_for :title
    t = t.blank? ? "" : "| #{t}"
    return t
  end

  def page_id
    if id = content_for(:body_id) and id.present?
      return id
    else
      base = controller_base
      return "#{base}-#{controller.action_name}"
    end
  end

  def controller_base
     controller.class.to_s.gsub("Controller", '').underscore.gsub("/", '_')
  end
  
  def page_class
    controller.class.to_s.gsub("Controller", '').underscore.gsub("/", '_')+" "+content_for(:page_class).to_s
  end

  BASE_PAGE_TITLE = "Recognize | Social Employee Recognition & Rewards"
  def base_page_title
    BASE_PAGE_TITLE
  end

  RESOURCE_ACTIONS = [:index, :new, :create, :edit, :update, :destroy]
  def page_title
    custom_title = content_for(:title)
    if custom_title === Recognize::Application::SKIP_CONTENT_FOR
      base_page_title
    elsif custom_title.present?
      "#{custom_title} | #{base_page_title}"
    else
      controller_action_page_title
    end 
  end

  def controller_action_page_title
    company_name = current_user && current_user.company.name.present? ? " | #{current_user.company.name}" : ""
    if RESOURCE_ACTIONS.include?(params[:action].to_sym)
      resourceful_page_title(company_name)
    else
      "#{pretty_action_name}#{company_name} | Recognize"
    end
  end

  def resourceful_page_title(company_name)
    case params[:action].to_sym
    when :index
      "#{controller_base.humanize}#{company_name} | Recognize"
    when :new, :edit
      "#{pretty_action_name} #{controller_base.singularize.humanize}#{company_name} | Recognize"    
    else
      "#{controller_base.humanize} #{pretty_action_name}#{company_name} | Recognize"    
    end
  end

  def pretty_action_name
    controller.action_name.humanize
  end

  BASE_DESCRIPTION = "Promote your reputation with professional recognition. A social employee recognition for your company and your professional network. Sign in with Yammer."
  def page_description
  
    specific_description = content_for(:description)
    
    if specific_description
      description =  "#{specific_description} Recognize is a social recognition network. Sign up to grow your professional reputation."
    else 
      description = BASE_DESCRIPTION
    end
    
    return description
  end

end