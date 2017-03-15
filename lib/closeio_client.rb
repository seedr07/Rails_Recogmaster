module CloseioClient

  def self.included(base)
    base.class_eval do 

      def closeio
        @closeio_client ||= (closeio_api_key.present? && !Rails.env.test?) ? Closeio::Client.new(closeio_api_key) :  MockClient.new
      end

      def closeio_api_key
        Recognize::Application.config.credentials["closeio"]["api_key"] if Recognize::Application.config.credentials.has_key?("closeio")
      end

    end
    Closeio::Client.send(:include, Extensions)
    MockClient.send(:include, Extensions)
  end

  class MockClient
    def list_leads(*args)
      return {}
    end

    def upsert_contact(*args)
      find_lead_and_contact_for(*args)
    end

    def find_lead_and_contact_for(*args)
      [Hashie::Mash.new(id: ""), Hashie::Mash.new(id: "")]
    end

    def create_lead(*args)
      return Hashie::Mash.new()
    end

    def update_lead(*args)
      return Hashie::Mash.new()
    end

    def email_template_by_name(name)
      Hashie::Mash.new({"body"=>
      "{{contact.first_name}},<br><br>We received your inquiry in regards to our Recognition platform and our team is excited to demonstrate how we can help {{lead.name}} unlock your employees potential. I've included some best practices below for review. Please answer the following questions so we can better prepare for a demonstration.<br><br><ol><li>How many total employees are there in your organization?</li><li>Do you use an internal platform such as Yammer, Slack, Sharepoint, Jira, etc?</li><li>Are you interested in our native mobile application for outside employees?&nbsp;</li><li>When are you and your team available for a demo?&nbsp;</li></ol><br>Engagement strategy overview:<br><ul><li>Stream the recognitions on a TV in the lobby for top-of-mind.    </li><li>Create three rewards that are easy to administer, create experiences for staff, and are close to free (parking spot, pizza party for team at end of day, half day off).    </li><li>Nominate staff through a nomination custom badge. Acknowledge these employees each month in a company email.&nbsp;</li></ul><br>You can review our Best Practices Handbook here:&nbsp;<a href=\"https://recognizeapp.com/best-practices-handbook.pdf\" target=\"_blank\">https://recognizeapp.com/best-practices-handbook.pdf</a><br><br>Read our strategy here:&nbsp;<a href=\"https://recognizeapp.com/company-engagement-strategy.pdf\" target=\"_blank\">https://recognizeapp.com/company-engagement-strategy.pdf</a><br><br>Go to&nbsp;<a href=\"http://support.recognizeapp.com/\" target=\"_blank\">http://support.recognizeapp.com</a>&nbsp;for our knowledge base.<br><br>Email&nbsp;<strong><a href=\"mailto:support@recognizeapp.com\" target=\"_blank\">support@recognizeapp.com</a></strong>&nbsp;if you need anything.<br><br>We look forward to the working with you.<br><br>Cheers,<br><br>",
       "attachments"=>[],
       "name"=>"Initial email response",
       "date_updated"=>"2016-01-15T16:22:21.974000+00:00",
       "created_by"=>"user_285b6Uo64w1sDxsaSMQzh58GXy1uiFsoVpmfwAvqsXR",
       "body_preview"=>
        "{{contact.first_name}},  We received your inquiry in regards to our Recognition platform and our team is excited to demonstrate how we can help {{lead.name}} unlock your employees potential. I've incl",
       "organization_id"=>"orga_BkzrERY8EYZr365BodfUCExnpP1tkydIwxFwxg6u5Qo",
       "updated_by"=>"user_285b6Uo64w1sDxsaSMQzh58GXy1uiFsoVpmfwAvqsXR",
       "date_created"=>"2016-01-11T22:16:07.902000+00:00",
       "subject"=>"Recognize",
       "id"=>"tmpl_mpsXddywjdkka8TCHKgTZUn2cTDRSSeAHV9GzuktiTa",
       "is_shared"=>true})
    end

    def render_email_templates(*args)
      Hashie::Mash.new(subject: "This is the subject", body: "This is the body")
    end

    def method_missing(m, *args, &block)  
      log "#{m} - #{args}"  
      return Hashie::Mash.new(id: "")
    end     

    def log(msg)
      Rails.logger.debug "[CloseioClient::MockClient] #{msg}"
    end
  end

  module Extensions

    MultipleLeadsForCompanyException = Class.new(StandardError)

    def find_lead_for_company(company)
      response = list_leads("url:#{company.domain}")
      response = list_leads("url:www.#{company.domain}") if response.total_results == 0
      return nil if response.total_results == 0
      raise ::CloseioClient::Extensions::MultipleLeadsForCompanyException if response.total_results > 1
      return response.data[0]      

    rescue ::CloseioClient::Extensions::MultipleLeadsForCompanyException => e
      ExceptionNotifier.notify_exception(e, data: { company: company.domain}) 
      return response.data[0]
    end

    def find_lead_and_contact_for(user)
      lead = find_lead_for_company(safe_company(user))
      contact = contact_from_lead(lead, user)
      return [lead, contact]
    end

    def upsert_contact(user_or_id)
      user = user_or_id.kind_of?(User) ? user_or_id : User.find(user_or_id)
      company = safe_company(user)
      lead, contact = find_lead_and_contact_for(user)

      if lead.present?
        Rails.logger.info "Upserting contact to Close(existing lead): #{user.email}"
        response = update_lead(lead.id, lead_payload(user, lead, contact))
      else
        Rails.logger.info "Upserting contact to Close(creating lead): #{user.email}"
        response = create_lead(lead_payload(user))
      end
      
      lead = response
      contact = contact_from_lead(lead, user)
      return [lead, contact]
    end

    def lead_payload(user, existing_lead=nil, existing_contact=nil)
      params = {}
      company = safe_company(user)

      params[:name] = company.try(:name) || company.domain unless existing_lead.present?
      params[:url] = company.domain
      params[:contacts] = [contact_payload(user, existing_contact)]

      custom = {}
      custom[:requested_user_count] = company.requested_user_count if company.requested_user_count.present?
      custom["auth:yammer"] = true if user.authentications.yammer.present?
      custom["auth:office365"] = true if user.authentications.office365.present?
      custom["auth:google"] = true if user.authentications.google.present?

      params[:custom] = custom if custom.present?
      return params
    end

    def safe_company(user)
      user.try(:company) || Company.from_email(user.email)
    end

    NAME_PLACEHOLDER = "NAME_NOT_YET_SET"
    def contact_payload(user, existing_contact=nil)
      data = {
        title: user.job_title,
        emails: [{type: "office", email: user.email}]
      }

      if existing_contact.present?
        data[:name] = user.full_name if user.first_name.present? && existing_contact.name == NAME_PLACEHOLDER
      elsif user.first_name.present?
        data[:name] = user.full_name
      else
        data[:name] = NAME_PLACEHOLDER
      end
      data[:id] = existing_contact.id if existing_contact

      if user.phone
        existing_phone_numbers = existing_contact.phones || [] 
        if !existing_phone_numbers.map(&:phone).include?(user.phone)
          data[:phones] = existing_phone_numbers + [{type: "office", phone: user.phone}] 
        end
      end
      return data
    end

    def email_template_by_name(name)
      set = list_email_templates
      return nil if set.total_results == 0
      return set.data.detect{|template| template.name == name}
    end

    def contact_from_lead(lead, user)
      return nil unless lead.present? && lead.contacts.present?
      lead.contacts.detect{|c| c.emails.detect{|e| e.email.downcase == user.email.downcase}}
    end
  end
end