#wrapper for Oauth/Omniauth
#this will present a consistent interface for different providers
#TODO: the current implementation will be yammer specific
#      refactor to be more modular if/when we bring more providers on board
class OauthService
  attr_accessor :oauth, :oauth_provider, :data, :origin, :strategy, :params
  delegate :provider, :uid, :except, :credentials, to: :oauth
  delegate :data, :email, :first_name, :last_name, :image, :default_image?, to: :oauth_provider
  
  def initialize(env)
    if env
      @oauth = env["omniauth.auth"]
      @origin = env["omniauth.origin"]
      @strategy = env["omniauth.strategy"]
      @params = env["omniauth.params"]
      @oauth_provider = BaseProvider.factory(@oauth)
    else
      @oauth, @origin, @strategy, @params, @data = OpenStruct.new, OpenStruct.new, OpenStruct.new, OpenStruct.new, OpenStruct.new
    end
  end
  
  def origin
    if @origin
      uri = URI.parse(@origin)
      existing_params = Rack::Utils.parse_nested_query(uri.query)
      uri.query = existing_params.merge(params).to_param
      return uri.to_s
    end
  end

  def yammer?
    @oauth.provider == "yammer"
  end
  
  def google?
    @oauth.provider == "google_oauth2"
  end
  
  class BaseProvider
    attr_accessor :oauth, :data
    
    def initialize(oauth)
      @oauth = oauth
    end
    
    def self.factory(oauth)
      return BaseProvider.new(oauth) unless oauth.respond_to?(:provider)

      case oauth.provider.to_s
      when "yammer"
        YammerProvider.new(oauth)
      when "google_oauth2"
        GoogleProvider.new(oauth)
      when "office365"
        Office365Provider.new(oauth)
      end
    end
  end
  
  class YammerProvider < BaseProvider
    def data
      data = oauth.extra.raw_info rescue OpenStruct.new#oauth might be nil if user has denied authentication            
    end
    
    def email
      #there is an email that comes through in the "info" portion of the oauth structure
      #but also there is the full set of emails in the "raw_info" portion
      #For now go with the "info" portion...but if need by, you can use
      #the commented out line below to get the rest of the emails
      # data.contact.email_addresses.first{|e| e.type == "primary"}.address
      oauth.info.email
    end
  
    def first_name
      data.first_name
    end
  
    def last_name
      data.last_name
    end
  
    def image
      oauth.info.image
    end
  
    def default_image?
      self.image.match(/no_photo/)
    end    
  end
  
  class GoogleProvider < BaseProvider
    def data
      @data ||= @oauth.info rescue OpenStruct.new#oauth might be nil if user has denied authentication            
    end
    
    def email
      #there is an email that comes through in the "info" portion of the oauth structure
      #but also there is the full set of emails in the "raw_info" portion
      #For now go with the "info" portion...but if need by, you can use
      #the commented out line below to get the rest of the emails
      # data.contact.email_addresses.first{|e| e.type == "primary"}.address
      oauth.info.email
    end
  
    def first_name
      data.first_name
    end
  
    def last_name
      data.last_name
    end
  
    def image
      oauth.info.image
    end
  
    def default_image?
      self.image.match(/no_photo/)
    end    
  end

  class Office365Provider < BaseProvider
    def data
      data = oauth.extra.raw_info rescue OpenStruct.new#oauth might be nil if user has denied authentication            
    end
    
    def email
      #there is an email that comes through in the "info" portion of the oauth structure
      #but also there is the full set of emails in the "raw_info" portion
      #For now go with the "info" portion...but if need by, you can use
      #the commented out line below to get the rest of the emails
      # data.contact.email_addresses.first{|e| e.type == "primary"}.address
      oauth.info.email
    end
  
    def first_name
      data.givenName
    end
  
    def last_name
      data.surname
    end
  
    def image
      nil#oauth.info.image
    end
  
    def default_image?
      true#self.image.match(/no_photo/)
    end   

    def job_title
      data.jobTitle
    end   
  end
end