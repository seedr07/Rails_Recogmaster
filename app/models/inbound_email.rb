class InboundEmail < ActiveRecord::Base
  INBOUND_DOMAIN = "inbound.recognizeapp.com"

  validates :data, presence: true
  serialize :data, JSON

  validates :sender_email, presence: true
  validate :valid_event_type

  before_validation :set_status, on: :create
  before_validation :set_sender_email, on: :create

  after_commit :process!

  STATUSES = [UNPROCESSED=1, PENDING=2, PROCESSED=3, ERRORED=4]

  def self.release!(user)
    where(status: UNPROCESSED, sender_email: user.email).each do |email|
      email.release!
    end
  end

  def release!
    return if [PROCESSED, ERRORED].include?(status)

    if recipient_emails.blank?
      handle_no_recipients! 
    else
      recognition = sender.recognize!(recipient_emails, badge, message, post_to_yammer_wall: true, from_inbound_email_id: self.id)
      InboundEmailNotifier.confirmation(recognition).deliver
    end

    return recognition
  rescue Exception => e
    exception_data =  {inbound_email_id: self.id, sender_email: self.sender_email, recipients: recipient_emails}
    exception_data[:recognitione_errors] = recognition.errors.full_messages.to_sentence if recognition.errors.present?
    ExceptionNotifier.notify_exception(e, {data: exception_data})
  ensure
    self.update_column(:status, ERRORED)    
  end

  def sender
    User.where(email: sender_email).first
  end

  def recipient_emails
    filter_legit_emails(data["msg"]["to"])
  end

  def cc_emails
    filter_legit_emails(data["msg"]["cc"])
  end

  def badge
    sender.company.company_badges.first
  end

  def subject
    data["msg"]["subject"]
  end

  def text
    data["msg"]["text"]
  end

  def html
    data["msg"]["html"]
  end

  def message
    "#{subject}: #{text}"
  end

  private
  def handle_no_recipients!
    InboundEmailNotifier.missing_recipients(self).deliver
  end

  def filter_legit_emails(set)
    set
      .flatten
      .select{|item| item && item.match(Authlogic::Regex.email)}
      .reject{|item| item.match(/#{INBOUND_DOMAIN}/)}
  end

  def valid_event_type
    if data["event"] != "inbound"
      errors.add(:base, "Data is not an inbound event as is of type: #{data['event']}")
    end
  end

  def set_status
    self.status = UNPROCESSED
  end

  def set_sender_email
    self.sender_email = data["msg"]["from_email"]
  end

  def process!
    if sender.present? && sender.active?
      release!
    else
      if sender
        UserNotifier.verification_email(sender).deliver
      else
        User.signup!(email: sender_email, from_inbound_email_id: self.id)
      end
    end
  end

end
