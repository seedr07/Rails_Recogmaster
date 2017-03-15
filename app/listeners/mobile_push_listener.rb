class MobilePushListener

  def on_recognition_created(recognition)
    recognition.user_recipients.each do |recipient|
      RecognitionRecipientNotifier.notify(recognition, recipient)
    end
  end

  class RecognitionRecipientNotifier

    attr_reader :recognition, :recipient

    def self.notify(recognition, recipient)
      new(recognition, recipient).notify
    end

    def initialize(recognition, recipient)
      @recognition = recognition
      @recipient = recipient
    end

    def notify
      return unless has_all_credentials?
      RestClient.post(PUSH_URL, payload.to_json, headers)
    end

    private
    PUSH_URL = "https://push.ionic.io/api/v1/push"

    def credentials
      Recognize::Application.config.credentials["mobile_app"]
    end

    def device_tokens
      @device_tokens ||= recipient.device_tokens.map(&:token)
    end

    def has_all_credentials?
      credentials.present? && 
      ionic_app_id.present? && 
      authorization_token.present? && 
      device_tokens.present?
    end

    def ionic_app_id
      credentials["ionic_app_id"]
    end

    def authorization_token
      credentials["authorization_token"]
    end

    def headers
      {
        :content_type => :json, 
        :accept => :json,
        "X-Ionic-Application-Id" => ionic_app_id,
        "Authorization" => "Basic #{authorization_token}"
      }
    end

    def message
      "#{recognition.sender.full_name} #{I18n.t('dict.recognizes')} you!"
    end

    def payload
      {
        tokens: device_tokens,
        production: false,#Rails.env.production?,
        notification: {
          alert: message,
          ios: ios_payload,
          android: android_payload
        }
      }
    end

    def ios_payload
      {
        badge: 1,
        sound: "ping.aiff",
        expiry: Time.now.to_i,
        priority: 10,
        contentAvailable: 1,
        payload: attributes
      }
    end

    def android_payload
      {
        collapseKey: "foo",
        delayWhileIdle: true,
        timeToLive: 300,
        payload: attributes        
      }
    end

    def attributes
      {
        action: "recognitions:show",
        id: recognition.recognize_hashid
      }
    end
  end
end