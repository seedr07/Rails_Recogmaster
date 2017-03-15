module NominationsHelper
  def add_recipient(user, name=nil)
    if user.kind_of?(User)
      str = %Q(var o = new window.R.pages["nominations-new"];o.addRecepient({'id': #{user.id}, email : '#{user.email}', name: '#{user.full_name}'}))
      page.execute_script(str)
    elsif user.kind_of?(Team)
      str = %Q(var o = new window.R.pages["nominations-new"];o.addRecepient({'id': #{user.id}, 'type': 'Team'}))
      page.execute_script(str)
    else
      name = user if name.nil?
      str = %Q(var o = new window.R.pages["nominations-new"];o.addRecepient({'email' : '#{user}', name: '#{name}'}))
      page.execute_script(str)
    end
  end
  
end