class AvatarAttachment < Attachment
  mount_uploader :file, AvatarAttachmentUploader#, {validate_integrity: false}

  belongs_to :user

#  validates_integrity_of :file, if: :should_validate_file

  protected
  
  def should_validate_file
    # validate local files only
    # because the only way right now to do remote files
    # is via yammer sign in
    return self.remote_file_url.blank?
  end
end