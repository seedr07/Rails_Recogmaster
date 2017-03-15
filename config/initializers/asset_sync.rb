if defined?(AssetSync)
  aws = Rails.configuration.credentials['aws']
  AssetSync.configure do |config|
    config.enabled = false
    config.fog_provider = 'AWS'
    config.fog_directory = aws['bucket']
    config.aws_access_key_id = aws["aws_access_key_id"]
    config.aws_secret_access_key = aws["aws_secret_access_key"]   
    config.fog_region = aws["region"]

    # config.run_on_precompile = false
    
    #
    # Don't delete files from the store
    # config.existing_remote_files = "keep"
    #
    # Automatically replace files with their equivalent gzip compressed version
    # config.gzip_compression = true
    #
    # Use the Rails generated 'manifest.yml' file to produce the list of files to 
    # upload instead of searching the assets directory.
    config.manifest = true
    #
    # Fail silently.  Useful for environments such as Heroku
    # config.fail_silently = true
  end
end