FactoryGirl.define do
  factory :oauth_application, class: Doorkeeper::Application do
    name "Recognize Slack App"
    uid "586e2df820fe8c360ac1318b30fbf9ae0b2330ea092e84dae6215852c77e9f23"
    secret "e204189e26b2b8b96f239e46f7ed103da2413eeb8fc070ebcb780817e1c5aa45"
    redirect_uri "urn:ietf:wg:oauth:2.0:oob"
    scopes ""
  end

  factory :trusted_oauth_application, class: Doorkeeper::Application do
    name "Recognize Slack App"
    uid "586e2df820fe8c360ac1318b30fbf9ae0b2330ea092e84dae6215852c77e9f23"
    secret "e204189e26b2b8b96f239e46f7ed103da2413eeb8fc070ebcb780817e1c5aa45"
    redirect_uri "urn:ietf:wg:oauth:2.0:oob"
    scopes "profile read write admin trusted"
  end

end