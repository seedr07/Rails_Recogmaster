if Rails.env.production?
  CarrierWave.configure do |config|
    config.fog_credentials = {
      :provider               => 'AWS',
      :aws_access_key_id      => Recognize::Application.config.credentials['aws']['aws_access_key_id'],                        
      :aws_secret_access_key  => Recognize::Application.config.credentials['aws']['aws_secret_access_key'],                        
      :region                 => Recognize::Application.config.credentials['aws']['region']
    }
    config.fog_directory  = Rails.configuration.credentials['aws']['bucket']
    config.fog_public     = true
    config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}
  end
else
  CarrierWave.configure do |config|
    config.storage = :file
    config.asset_host = ActionController::Base.asset_host
  end  
end

module CarrierWave
  module MiniMagick
    def quality(percentage)
      manipulate! do |img|
        img.quality(percentage.to_s)
        img = yield(img) if block_given?
        img
      end
    end
  end
end