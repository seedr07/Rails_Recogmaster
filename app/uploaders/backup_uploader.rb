# encoding: utf-8
class BackupUploader < CarrierWave::Uploader::Base
  storage :fog
  def store_dir
    "backups/db/"
  end
end
