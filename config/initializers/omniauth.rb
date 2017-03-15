# Rails.application.config.after_initialize do
#   puts "omniauth after init"
#   Rails.application.config.middleware.use OmniAuth::Builder do
#     provider :yammer, 'A6ItevIO7XS1rxIKzdPCw', 'QXoUPFvY5Pzxuwzq7VZ5JVLrJLU6S7oCjb979ENt0Y', {client_options: {ssl: {ca_file: Rails.configuration.local_config['ca_cert_file']}}}
#   end
# end
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :yammer, 
    Recognize::Application.config.credentials['yammer']['client_id'], 
    Recognize::Application.config.credentials['yammer']['client_secret'], 
    {
      provider_ignores_state: true,
      client_options: {
        ssl: {ca_file: Rails.configuration.local_config['ca_cert_file']}, 
        token_method: :get, 
        token_url: "https://www.yammer.com/oauth2/access_token.json"
      }
    }

  provider :google_oauth2, "441375773969.apps.googleusercontent.com", "xdnmEVf5UgRZK5xy7NfvWWCG", 
    {
     scope: "userinfo.email,userinfo.profile,https://www.google.com/m8/feeds/,plus.me",
     access_type: 'online', 
     approval_prompt: '',
     client_options: {ssl: {ca_file: Rails.configuration.local_config['ca_cert_file']}}}

  if Recognize::Application.config.credentials['o365'].present?
    provider :office365, 
      Recognize::Application.config.credentials['o365']['client_id'],
      Recognize::Application.config.credentials['o365']['secret']
  end
end

# OmniAuth.config.on_failure = AuthenticationsController.action(:oauth_failure)
# Wrap this in a proc b/c in development env, the reloading of classes fudges with this
# due to middleware calling this presumably before class reloading middleware
OmniAuth.config.on_failure = Proc.new { |env|
  AuthenticationsController.action(:oauth_failure).call(env)
}
