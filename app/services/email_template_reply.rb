class EmailTemplateReply
  attr_reader :user, :template
  
  NoMatchingTemplateError = Class.new(StandardError)

  def self.send_sales_reply(user_id_or_email)
    reply = new_sales_reply(user_id_or_email)
    reply.send! unless reply.has_been_sent?
  end

  def self.new_sales_reply(user_id_or_email)
    new(user_id_or_email, get_sales_reply_template)
  end

  DEFAULT_SALES_INQUIRY_REPLY_TEMPLATE_NAME = "Initial email response"
  def self.sales_reply_template_name
    DEFAULT_SALES_INQUIRY_REPLY_TEMPLATE_NAME
  end

  def self.get_sales_reply_template
    Recognize::Application.closeio.email_template_by_name(self.sales_reply_template_name)
  end

  def initialize(user_id_or_email, template)
    @user = safe_user(user_id_or_email)
    @template = template
  end

  def safe_user(user_id_or_email)
    if user_id_or_email.kind_of?(User)
      return user_id_or_email
    elsif user_id_or_email.to_s.match(/\@/)
      User.find_or_initialize_by(email: user_id_or_email)
    else
      User.find(user_id_or_email)
    end
  end

  def send!
    send_reply
  end

  def has_been_sent?
    get_sent.present? if template.present?
  end

  def send_reply
    raise NoMatchingTemplateError if template.blank?

    # must make sure contact is in close in order to
    # have record to interpolate template against
    Rails.logger.info "EmailTemplateReply#send_reply - About to upsert"
    lead, contact = Recognize::Application.closeio.upsert_contact(user)
   
    rendered = Recognize::Application.closeio.render_email_templates(template.id, lead_id: lead.id, contact_id: contact.id)
    subject  = rendered.subject
    body = rendered.body
    
    sender = User.find_by_id(20380) || User.system_user
    UserNotifier.from_template(sender, user,subject,body).deliver unless Rails.env.test?

    stash_sent

    return true
  rescue NoMatchingTemplateError => e
    ExceptionNotifier.notify_exception(e, {data: {user: user}})
  rescue Exception => e
    ExceptionNotifier.notify_exception(e, {data: {user: user}})
    raise e
  end

  def stash_sent
    $redis.sadd(template_key, Time.now)
  end

  def get_sent
    $redis.smembers(template_key)
  end

  def reset_sent
    $redis.del(template_key)
  end

  def template_key
    "template_replies:#{template.name}:#{user.email}"
  end

end