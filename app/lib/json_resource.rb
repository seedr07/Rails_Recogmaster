#########################################################################
#
#   Class JsonResource
#
#   This class converts an obj to be a specific json object
#   that will serve as the standardized response for all ajax 
#   requests. 
#
#   Basically, the idea for this comes from the following articles(which are inter-related):
#
#     http://stackoverflow.com/questions/8184512/ajax-forms-with-rails-3-best-practice
#     http://www.alfajango.com/blog/rails-3-remote-links-and-forms/
#       (see the section about "What Rails.js does NOT do")
#
#   Where the idea is that rails will not handle the response, its up to
#   the application to handle responses, so I've developed a custom 
#   application based JSON protocol
#
#   The protocol will be as follows:
#
#   NOTE: the keys listed here follow the rails convention for
#         the html id's for inputs generated from rails helpers
#
#   Error Case
#     {
#        'type'   => 'error',
#        'errors' => {"base"=> "This is a message that applies to the whole model/form",
#                     "klass1_attribute1" => "this is an error message applying to attribute1 of klass1", 
#                     "klass1_attribute2" => "this is an error message applying to attribute2 of klass1", 
#                     "klass2_attribute1" => "this is an error msg applying to attribute1 of klass2"}
#     }
#
#   Simple Success Case
#     {
#        'type' => 'success',
#        'obj1_klass' => {
#          '<arg1>' => '<val1'>,
#          '<arg2>' => '<val2'>,
#         }
#        'obj2_klass' => {
#          '<arg1>' => '<val1'>,
#          '<arg2>' => '<val2'>,
#        }
#        .....etc
#     }
#   Redirection Case
#     {
#        'type'     => 'redirect',
#        'location' => "http://www.example.com"
#     }
#
#   Render case
#     {
#         'type' => 'render',
#         'container' => "<div>whatever</div>",
#         'target' => "idOfTheDiv"
#     }
#
#   onsuccess update
#     {
#         'type'   => 'onsuccess',
#         'method' => "doMe",
#         'params' => [arg1, arg2, arg3]
#     }
#
# CALLBACKS:
#
#     oncomplete:
#       (NOTE: ATM(8/12/12) this feature is half-baked...and not implemented in js)
#
#       this is a javascript callback that can be specified in the controller
#       gives the ability to execute javascript, no matter which case is handled
#
#       Usage: 
#         respond_with @project, location: save_successful_redirect_location, oncomplete: {method: "updateUi", params: ""}
# 
#       And this will be appended to all json responses:
#       {
#         'oncomplete' => { 
#           'method' => "doMe",
#           'params' => [arg1, arg2, arg3]
#          }
#       }      
class JsonResource
  include ActionView::RecordIdentifier#gives us dom_id()
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers
  
  attr_accessor :obj, :controller, :includes, :location, :onsuccess, :oncomplete, :response
  
  def initialize(obj, controller, includes=[], options={})
    @obj = obj
    @includes = includes.respond_to?(:each) ? includes : [includes]
    @controller = controller
    @onsuccess = options[:onsuccess]
    @oncomplete = options[:oncomplete] || {}
    @location = options[:location] 
    @notice = options[:notice]
    @response = {}
  end
  
  def to_json

    json = case determine_type
      when :error
        json_for_errors
      when :success
        json_for_success
      when :redirect
        json_for_redirection
      when :render
        json_for_render
      when :onsuccess
        json_for_onsuccess
      else
        raise "Unknown error trying to convert to json object"
      end    

    # Logic behind FormUuid
    # We can have situations where we have many forms on a page and some of those many forms can 
    # be for new records. When the forms are for existing records, we simply pass along the id attribute
    # and use that to find the correct form to show errors for. 
    # For new records, we need to generate a uuid which is set via javascript and added as a data attribute
    # to the form and set as a request header. 
    # We need both 
    if form_uuid = controller.request.headers['X-Form-UUID']
      json['formuuid'] = form_uuid
    end
    
    json.merge(json_for_oncomplete).to_json
  end

  def has_errors?
    !(obj.errors.blank? and includes.all?{|i| i.errors.blank?})
  end
  
  protected

  # The order of the if/else's here matters as it determines
  # priorities of callbacks.
  #
  # 1. errors - this is always priority.  
  #
  # 2. Onsuccess trumps redirect, because redirect is sort of the base case
  #    of a successful form post.  However, in certain conditions, we may 
  #    want to run a javascript method to update the ui or do further
  #    form processing.  The main example is when a user clicks "save" but has
  #    not registered yet.  So they click save, and up pops a dialog where they register
  #    Then upon successful registration we want to close the dialog and submit the original
  #    design brief form.
  #    In other cases of registration we just redirect the user to their homepage
  #
  # 3. render - this isn't implemented yet, but as it may turn out, this may be higher
  #    priority than redirect
  def determine_type

    if has_errors?
      :error
    elsif should_run_onsuccess?
      :onsuccess
    elsif should_redirect?
      :redirect
    elsif should_show_success?
      :success
    elsif should_render?
      :render
    else
      nil
    end    
  end
  

  #   Error Case
  #     {
  #        'errors' => {"klass1_base"=> "This is a message that applies to the whole model/form",
  #                     "klass1_attribute1" => "this is an error message applying to attribute1 of klass1", 
  #                     "klass1_attribute2" => "this is an error message applying to attribute2 of klass1", 
  #                     "klass2_attribute1" => "this is an error msg applying to attribute1 of klass2"}
  #     }
  def json_for_errors
    h = {}

    obj.errors.each do |attr, msg|
      if attr.to_s == "base"
        identifier = "base"
        h[identifier] ||= []
        h[identifier] << msg
        # h[identifier] << obj.errors.full_message(attr)

      #handle association errors
      #the logic is that with validated associations it will show up in the basic
      #error array, eg :profile_data => "is invalid"
      #so we detect if we call that attribute on the object and it returns not
      #a primitive but an object who includes ActiveModel::Validations
      #meaning this attribute is an object who has its own errors
      elsif obj.respond_to?(attr) and obj.send(attr).class.ancestors.include?(ActiveModel::Validations)
        association = obj.send(attr)
        
        #its possible we just want to manually want to tack errors onto
        #an association-based attribute
        #if the association itself has no errors, we can assume this is the case
        if association.errors.present?
          identifier_base = "#{dom_class(obj)}_#{dom_class(association)}"
          association.errors.each do |attr, msg|
            identifier = identifier_base+"_#{attr}"
            h[identifier] ||= []
            if msg.starts_with?("^")
              h[identifier] << msg.gsub(/^\^/,'')
            else
              h[identifier] << "#{association.class.human_attribute_name(attr)} #{msg}"
            end
          end
        else
          identifier = "#{dom_class(obj)}_#{attr}"
          h[identifier] ||= []
          h[identifier] << "#{msg}"
        end
        
      # handle collections of objects(bulk edit forms)
      elsif obj.respond_to?(attr) and (obj.send(attr).class.ancestors.include?(Enumerable))
        collection = obj.send(attr)

        if collection.respond_to?(:errors) && collection.errors.present?
          collection.errors.each do |object_id, errors|
            errors.each do |object_attr, msg|
              identifier = "#{dom_class(obj)}_#{object_id}_#{object_attr}"
              h[identifier] = "#{obj.class.human_attribute_name(object_attr)} #{msg}"
            end
          end
        end
        identifier = "#{dom_class(obj)}_#{attr}"
        h[identifier] ||= []
        h[identifier] << "#{msg}"          

      #this will handle nested attribute assignments
      #errors on nested attributes show up in the form of `association.attribute`
      elsif attr.to_s.match(/\./)
        association, nested_attribute = attr.to_s.split(".")
        association_klass = association.to_s.classify.constantize
        
        identifier = "#{dom_class(obj)}_#{association}_attributes_#{nested_attribute}"
        h[identifier] ||= []

        if msg.starts_with?("^")
          h[identifier] << msg.gsub(/^\^/,'')
        else
          h[identifier] << "#{association_klass.human_attribute_name(nested_attribute)} #{msg}"
        end
        
      else
        identifier = "#{dom_class(obj)}_#{attr}"
        h[identifier] ||= []
        if msg.starts_with?("^")
          h[identifier] << msg.gsub(/^\^/,'')
        else
          h[identifier] << "#{obj.class.human_attribute_name(attr)} #{msg}"
        end
      end

    end
    
    error_response = {'type' => 'error', 'errors' => h, 'id' => obj.id}

    return error_response
  end
      
  #   Redirection Case
  #     {
  #        'location' => "http://www.example.com"
  #     }  
  def json_for_redirection
    u = location || url_for(obj)
    h = {'type' => 'redirect', 'location' => u}
    h = h.merge(json_for_obj_and_includes)
    return h
  end

  def should_redirect?
    return true if !has_errors? and obj.persisted? and @location.present?
  end

  def json_for_success
    h = {'type' => 'success'}

    h = h.merge(json_for_obj_and_includes)
    h = h.merge('flash' => {'notice' => @notice}) if @notice.present?
    return h
  end
  
  def json_for_obj_and_includes
    h = {}
    set = [obj]+includes
    set.each do |o|
      if o.class.respond_to?(:attributes_for_json)
        h[o.class.to_s.underscore] = o.class.attributes_for_json.inject({}){|hash, a|
          attribute_value = o.send(a)
          if attribute_value.kind_of?(CarrierWave::Uploader::Base) # hack!
            hash.merge!(attribute_value.as_json)
          else
            hash[a] = attribute_value
          end
          hash
        }
      else
        h[o.class.to_s.underscore] = o.attributes
      end
    end
    return h
  end

  def should_show_success?
    return true if !has_errors? and obj.persisted? and @location.blank?
  end
  
  #   Render case
  #     {
  #         'container' => "<div>whatever</div>",
  #         'target' => "idOfTheDiv"
  #     }
  #
  def json_for_render
    raise "Not Implemented"
  end

  def should_render?
    raise "Not Implemented"
  end

  #   Onsuccess update
  #     {
  #         'method' => "doMe",
  #         'params' => [arg1, arg2, arg3]
  #     }
  def json_for_onsuccess
    os = onsuccess.dup.stringify_keys!
    h = {'type' => 'onsuccess', 
         'method' => os['method'], 
         'params' => os['params'] }
  end

  def should_run_onsuccess?
    onsuccess.present?
  end

  def json_for_oncomplete
    oc = oncomplete.dup.stringify_keys!
    h = {'oncomplete' => {
         'method' => oc['method'], 
         'params' => oc['params'] } }
  end
  
end