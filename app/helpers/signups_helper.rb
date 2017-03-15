module SignupsHelper
  def get_section_classes

    case section_to_show
    when :first_last_name
      home_class = ""
      first_last_name_class = "current"
      password_class = ""
    when :password
      home_class = ""
      first_last_name_class = ""
      password_class = "current"
    else
      home_class = "current"
      first_last_name_class = ""
      password_class = ""
    end
  
    return home_class, first_last_name_class, password_class
  
  end  
  
  def section_to_show
    if @user.persisted? and @user.first_name.blank?
      :first_last_name
    elsif @user.persisted? and @user.crypted_password.blank?
      :password
    else
      :home
    end
  end
  
end
