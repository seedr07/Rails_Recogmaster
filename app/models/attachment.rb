#This is a generic attachment class...
#you could theoretically use it, but really
#you should create a subclass off this
#and specify a specific uploader that goes with it
#depending on the business case
class Attachment < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  attr_accessible :file, :owner
  
  belongs_to :owner, polymorphic: true, autosave: true
  scope :type, lambda{|type| where(owner_type: type)}

  #creates the appropriate subclass and saves
  #need to save here to save the attachment 
  def self.factory!(params={})
    type = params.delete(:type)
    file = params.delete(:file)
    a = self.new(params)
    a.type = type 
    a = a.becomes(type.constantize) if type
    a.update_attribute(:file, file)
    return a
  end
  
  #one convenient method to pass jq_upload the necessary information
  def to_jq_upload
    {
      "name" => read_attribute(:file),
      "size" => file.size,
      "url" => file.url,
      "show_url" => attachment_path(:id => id),
      "thumbnail_url" => file.thumb.url,
      "delete_url" => attachment_path(:id => id),
      "delete_type" => "DELETE" 
    }
  end  

  def small_thumb
    file.small_thumb
  end
  
  def thumb
    file.thumb
  end
  
  def url
    file.url
  end
  
  def default?
    url.match("icons/user-default") ? true : false
  end

  #subclasses are responsible for how they are attached
  def save_to_owner!(*args)
    raise "Subclass must define this method"
  end
end