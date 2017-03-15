class BackupAttachment < Attachment
  mount_uploader :file, BackupUploader#, {validate_integrity: false}

end