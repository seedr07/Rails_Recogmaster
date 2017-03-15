module RecognitionConcern
  module Notification
    extend ActiveSupport::Concern

    included do
      after_commit :notify_managers, on: :create
    end

    private
    def notify_managers
      msg_template = "%user% has been recognized with the #{badge.short_name} badge."
      self.user_recipients.each do |recipient|
        msg = msg_template.gsub("%user%", recipient.full_name)
        begin
          YammerManagerNotifier.delay.notify!(recipient.id, msg, yammer_og_object)
        rescue => e
          ExceptionNotifier.notify_exception(e)
        end
      end
    end
  end
end