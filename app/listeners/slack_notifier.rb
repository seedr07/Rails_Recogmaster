class SlackNotifier

  COMPANY_NOTIFICATION_CHANNEL = Rails.configuration.local_config['company_notification_channel'] || "#test"
  def on_company_created(company)
    Rails.logger.info "SlackNotifier#on_company_created: #{company.domain}|#{company.id}"
    url = "https://recognizeapp.com/admin?network=#{company.domain}"
    attachments = [{
      color: "good",
      fields: [
        {title: "Company", value: company.domain, short: true}, 
        {title: "Platform", value: platform(company), short: true},
        {title: "Invited", value: invited_status(company), short: true},
        {title: "Contact", value: "#{company.company_admin.full_name} - #{company.company_admin.email}", short: true},
        {title: "Contact Job Title", value: company.company_admin.job_title, short: true}
      ]
    }]
    Rails.logger.info "SlackNotifier#on_company_created: #{channel} - #{attachments}"
    ::Recognizebot.say(text: "<@josh|Josh> New signup: #{company.domain} - #{url}", attachments: attachments, channel: COMPANY_NOTIFICATION_CHANNEL)
  end

  def platform(company)
    auth = company.company_admin.authentications.first
    platform = if auth.present?
      auth.provider.humanize
    else
      "Standalone"
    end
  end

  def invited_status(company)
    status = company.company_admin.status
    if status.match(/^invited/)
      return status.humanize
    else
      "n/a"
    end
  end
end