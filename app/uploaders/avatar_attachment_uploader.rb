# encoding: utf-8

class AvatarAttachmentUploader < AttachmentUploader

  def default_url
    "icons/user-default.png"
  end
    
  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  version :small_thumb do
    process :resize_to_fill => [50, 50]
    process :quality => 100
  end

  version :thumb do
    process :resize_to_fill => [100, 100]
    process :quality => 80
  end
  
  # version :thumb_large do
  #   process :resize_to_fill => [300, 300]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    ["jpg", "jpeg", "gif", "png", "ico"]
  end
  
  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
