module Credentials
  class Base
    attr_accessor :file, :required_credentials, :credentials
    
    def initialize(f)
      @file = f
      
      check_has_required_files!
      
      @required_credentials = YAML.load(ERB.new(File.new(f+".sample").read).result)
      @credentials = YAML.load(ERB.new(File.new(f).read).result)

      check_has_all_required_credentials!
      
      return self
    end
  
    def apply_credentials_to_rails
      Rails.configuration.credentials = @credentials
    end

    protected
    def check_has_required_files!
      unless File.exists?(self.file+".sample")
        raise "You are missing the required sample credentials file.  Please create #{self.file}.sample which will list all the required credentials that are needed for deployment"
      end
      
      unless File.exists?(self.file)
        raise "You must create a credentials file.  Please copy #{self.file}.sample to #{self.file} and fill in the appropriate values"
      end
    end
    
    #check if all the top level credentials are there
    def check_has_all_required_credentials!
      unless (missing = (required_credentials.keys - credentials.keys)).empty?
        raise "You are missing some credentials required in order to deploy: #{missing}"
      end
    end
  end
  
  def self.load_credentials(rails_config)
    credentials = Base.new(Rails.root.to_s+'/config/credentials.yml')
    credentials.apply_credentials_to_rails
  end
end