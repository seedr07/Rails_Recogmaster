# https://gist.github.com/jjb/996510
# http://stackoverflow.com/questions/6158581/elegantly-using-kernelopen-for-https-via-open-uri
# For recognize, this allows us to use Carrierwave remote_file_url attribute to assign attachments
# via a remote file, where said url is https.  This was a problem on osx, and may or may not be a problem
# on other systems where the ruby does not have access to root certs.
if Rails.configuration.local_config["ca_cert_file"].present?
  require 'open-uri'
  require 'net/https'

  module Net
    class HTTP
      alias_method :original_use_ssl=, :use_ssl=
      def use_ssl=(flag)
        self.ca_file = Rails.configuration.local_config["ca_cert_file"]
        self.verify_mode = OpenSSL::SSL::VERIFY_PEER # ruby default is VERIFY_NONE!
        self.original_use_ssl = flag
      end
    end
  end
end