# class EmailLogger
#   def self.delivered_email(email)
#     body = email.html_part.present? ? email.html_part : (email.text_part.present? ? email.text_part : email.body.inspect)
#     debugger if body.blank?
#     EmailLog.create!(
#       :from => Array(email.from).join(", "),
#       :to => email.to.join(", "),
#       :subject => email.subject,
#       :body => body,
#       :date => email.date
#     )
#   rescue Exception => e
#     Rails.logger.warn "Failed logging email: #{email.inspect}"
#     ExceptionNotifier.notify_exception(e, data: {email: email})  unless email.to.include?("devexceptions@recognizeapp.com")            
#   end
# end
# Mail.register_observer(EmailLogger)