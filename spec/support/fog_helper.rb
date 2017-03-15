
Fog.mock!
if Rails.configuration.credentials['aws']['aws_access_key_id'].present?
  connection = Fog::Storage.new(
    :provider               => 'AWS',
    :aws_access_key_id      => Rails.configuration.credentials['aws']['aws_access_key_id'],                        
    :aws_secret_access_key  => Rails.configuration.credentials['aws']['aws_secret_access_key'],                        
    :region                 =>  Rails.configuration.credentials['aws']['region']
  )
  connection.directories.create(:key => 'recognize-test-assets')
end
