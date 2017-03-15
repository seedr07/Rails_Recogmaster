class NewCompanyAdminDigest
  def self.send!
    new.send!
  end

  def send!

    rows = new_companies.map do |company|
      row(company.domain, company.users.size, company.recognitions.size)
    end

    data = {color: "good", text: rows.join("\n")}
    Recognizebot.say(text: "Yesterday's new company activity", attachments: [data], channel: SlackNotifier::COMPANY_NOTIFICATION_CHANNEL) if new_companies.present?
  end

  def row(company, users, recognitions)
    # "#{domain_string_format % company} | #{numeric_string_format % users} | #{numeric_string_format % recognitions}"
    "#{company} has added #{users} users and has sent #{recognitions} recognitions."
  end

  def new_companies
    @companies ||= Company.where("created_at > ?",1.day.ago)
  end

  def domain_string_format
    @domain_string_format ||= "%#{max_domain_length+2}s"
  end

  def numeric_string_format
    @numeric_string_format ||= "%13s"
  end

  def max_domain_length
    @max_domain_length ||= new_companies.map(&:domain).max_by{|d| d.length }.length
  end

end