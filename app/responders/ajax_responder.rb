#This module intercepts all ajax requests that
#do not explicitly specificy a dataType response
#and wraps them in a JsonResource object
module AjaxResponder
  def to_json
    
    #skip get requests
    unless get?
      resource = JsonResource.new(@resource, controller, includes, json_params)
      status = resource.has_errors? ? 422 : 200
      render :json => resource.to_json, :content_type => :json, status: status
    else
      to_format
    end
  end
  alias :to_js :to_json
  
  protected

  def json_params
    h = flash || {}
    if onsuccess.present?
      h.merge( onsuccess: onsuccess )
    elsif location
      h.merge( location: location )
    else
      h
    end
  end
  
  def flash
    self.options[:flash] || {}
  end
  
  def includes
    self.options[:includes] || []
  end
  
  def onsuccess
    self.options[:onsuccess] || Rack::Utils.parse_nested_query(controller.params[:onsuccess])
  end
  
  def location
    self.options[:location]
  end
  
  # def collection?
  #   @resources.count > 1
  # end
end